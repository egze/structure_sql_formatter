defmodule StructureSqlFormatter do
  @behaviour Mix.Tasks.Format

  alias NimbleOptions.ValidationError

  @impl true
  def features(_opts) do
    [extensions: [".sql"]]
  end

  @doc """
  Formats `structure.sql` to make the git diff easier to read.

  ## Options

  The StructureSqlFormatter options are:

  #{NimbleOptions.docs(StructureSqlFormatter.Options.definition())}

  """
  @impl true
  def format(sql, opts \\ []) do
    structure_sql_formatter_opts = Keyword.get(opts, :structure_sql_formatter_opts, [])

    case NimbleOptions.validate(
           structure_sql_formatter_opts,
           StructureSqlFormatter.Options.definition()
         ) do
      {:error, error} ->
        raise ArgumentError, format_error(error)

      {:ok, valid_opts} ->
        do_format(sql, valid_opts)
    end
  end

  defp do_format(sql, valid_opts) do
    sql
    |> remove_trailing_whitespace(valid_opts[:remove_trailing_whitespace])
    |> remove_version_specific_output(valid_opts[:remove_version_specific_output])
    |> remove_useless_comment_lines(valid_opts[:remove_useless_comment_lines])
    |> remove_pg_stat_statements_extension(valid_opts[:remove_pg_stat_statements_extension])
    |> remove_pg_buffercache_extension(valid_opts[:remove_pg_buffercache_extension])
    |> remove_comments_on_extensions(valid_opts[:remove_comments_on_extensions])
    |> remove_useless_version_specific_parts_of_comments(
      valid_opts[:remove_useless_version_specific_parts_of_comments]
    )
    |> reduce_noise_for_id_fields(valid_opts[:reduce_noise_for_id_fields])
    |> remove_inherited_tables(valid_opts[:remove_inherited_tables])
    |> remove_partitioned_tables(valid_opts[:remove_partitioned_tables])
    |> allow_restoring_postgres_11_output_on_postgres_10(
      valid_opts[:allow_restoring_postgres_11_output_on_postgres_10]
    )
    |> order_schema_migrations_values(valid_opts[:order_schema_migrations_values])
    |> cleanup_new_lines()
  end

  defp remove_trailing_whitespace(sql, true = _enabled) do
    sql
    |> String.replace(~r/[ \t]+$/m, "")
    |> String.replace(~r/\A\n{1,}/m, "")
    |> String.replace(~r/\n{2,}\z/m, "\n")
  end

  defp remove_trailing_whitespace(sql, _disabled), do: sql

  defp remove_version_specific_output(sql, true = _enabled) do
    sql
    |> String.replace(~r/^-- Dumped.*\n/m, "")
    # 9.5
    |> String.replace(~r/^SET row_security = off;\n/m, "")
    # 9.6
    |> String.replace(~r/^SET idle_in_transaction_session_timeout = 0;\n/m, "")
    # all older than 12
    |> String.replace(~r/^SET default_with_oids = false;\n/m, "")
    # 12
    |> String.replace(~r/^SET xmloption = content;\n/m, "")
    # 12
    |> String.replace(~r/^SET default_table_access_method = heap;\n/m, "")
  end

  defp remove_version_specific_output(sql, _disabled), do: sql

  defp remove_useless_comment_lines(sql, true = _enabled) do
    sql
    |> String.replace(~r/^--\n/m, "")
  end

  defp remove_useless_comment_lines(sql, _disabled), do: sql

  # Remove pg_stat_statements extension (its not relevant to the code)
  defp remove_pg_stat_statements_extension(sql, true = _enabled) do
    sql
    |> String.replace(~r/^CREATE EXTENSION IF NOT EXISTS pg_stat_statements.*\n/m, "")
    |> String.replace(~r/^-- Name: (EXTENSION )?pg_stat_statements;.*\n/m, "")
  end

  defp remove_pg_stat_statements_extension(sql, _disabled), do: sql

  defp cleanup_new_lines(sql) do
    sql
    |> String.replace_leading("\n", "")
    |> String.replace(~r/\n{2,}$/m, "\n")
  end

  # Remove pg_buffercache extension (its not relevant to the code)
  defp remove_pg_buffercache_extension(sql, true = _enabled) do
    sql
    |> String.replace(~r/^CREATE EXTENSION IF NOT EXISTS pg_buffercache.*\n/m, "")
    |> String.replace(~r/^-- Name: (EXTENSION )?pg_buffercache;.*\n/m, "")
  end

  defp remove_pg_buffercache_extension(sql, _disabled), do: sql

  # Remove comments on extensions, they create problems if the extension is owned by another user
  defp remove_comments_on_extensions(sql, true = _enabled) do
    sql
    |> String.replace(~r/^COMMENT ON EXTENSION .*\n/m, "")
    |> String.replace(~r/^-- Name: EXTENSION .*; Type: COMMENT;.*\n/m, "")
  end

  defp remove_comments_on_extensions(sql, _disabled), do: sql

  defp remove_useless_version_specific_parts_of_comments(sql, true = _enabled) do
    sql
    |> String.replace(~r/^-- (.*); Schema: ([\w_\.]+|-); Owner: -.*/, "-- \\1")
  end

  defp remove_useless_version_specific_parts_of_comments(sql, _disabled), do: sql

  # Reduce noise for id fields by making them SERIAL instead of integer+sequence stuff
  # This is a bit optimistic, but works as long as you don't have an id field thats not a sequence/uuid
  defp reduce_noise_for_id_fields(sql, true = _enabled) do
    sql
    |> String.replace(~r/^    id integer NOT NULL(,)?$/m, "    id SERIAL PRIMARY KEY\\1")
    |> String.replace(~r/^    id bigint NOT NULL(,)?$/m, "    id BIGSERIAL PRIMARY KEY\\1")
    |> String.replace(
      ~r/^    id uuid DEFAULT ([\w_]+\.)?uuid_generate_v4\(\) NOT NULL(,)?$/m,
      "    id uuid DEFAULT \\1uuid_generate_v4() PRIMARY KEY\\2"
    )
    |> String.replace(
      ~r/^    id uuid DEFAULT ([\w_]+\.)?gen_random_uuid\(\) NOT NULL(,)?$/m,
      "    id uuid DEFAULT \\1gen_random_uuid() PRIMARY KEY\\2"
    )
    |> String.replace(
      ~r/^CREATE SEQUENCE [\w\.]+_id_seq\s+(AS integer\s+)?START WITH 1\s+INCREMENT BY 1\s+NO MINVALUE\s+NO MAXVALUE\s+CACHE 1;$/m,
      ""
    )
    |> String.replace(~r/^ALTER SEQUENCE [\w\.]+_id_seq OWNED BY .*;$/m, "")
    |> String.replace(
      ~r/^ALTER TABLE ONLY [\w\.]+ ALTER COLUMN id SET DEFAULT nextval\('[\w\.]+_id_seq'::regclass\);$/m,
      ""
    )
    |> String.replace(
      ~r/^ALTER TABLE ONLY [\w\.]+\s+ADD CONSTRAINT [\w\.]+_pkey PRIMARY KEY \(id\);$/m,
      ""
    )
    |> String.replace(~r/^-- Name: (\w+\s+)?id; Type: DEFAULT.*$/m, "")
    |> String.replace(~r/^-- .*_id_seq; Type: SEQUENCE.*$/m, "")
    |> String.replace(~r/^-- Name: (\w+\s+)?\w+_pkey; Type: CONSTRAINT.*$/m, "")
  end

  defp reduce_noise_for_id_fields(sql, _disabled), do: sql

  defp remove_inherited_tables(sql, true = _enabled) do
    inherited_tables_regexp =
      ~r/-- Name: ([\w_\.]+); Type: TABLE.*\n\n[^;]+?INHERITS \([\w_\.]+\);/m

    inherited_tables =
      for [table | _] <- Regex.scan(inherited_tables_regexp, sql, capture: :all_but_first),
          do: table

    sql = String.replace(sql, inherited_tables_regexp, "")

    inherited_tables
    |> Enum.reduce(sql, fn inherited_table, sql_acc ->
      temp_sql =
        sql_acc
        |> String.replace(~r/-- Name: #{inherited_table} id; Type: DEFAULT\n/m, "")
        |> String.replace(~r/ALTER TABLE ONLY ([\w_]+\.)?#{inherited_table}[^;]+;\n/m, "")

      index_regexp = ~r/CREATE INDEX ([\w_]+) ON ([\w_]+\.)?#{inherited_table}[^;]+;/m

      inherited_table_indexes =
        for [inherited_table_index | _] <-
              Regex.scan(index_regexp, temp_sql, capture: :all_but_first),
            do: inherited_table_index

      inherited_table_indexes
      |> Enum.reduce(temp_sql, fn inherited_table_index, temp_sql_acc ->
        temp_sql_acc
        |> String.replace("-- Name: #{inherited_table_index}; Type: INDEX", "")
      end)
      |> String.replace(index_regexp, "")
    end)
  end

  defp remove_inherited_tables(sql, _disabled), do: sql

  defp remove_partitioned_tables(sql, true = _enabled) do
    # Postgres 12 pg_dump will output separate ATTACH PARTITION statements (even when run against an 11 or older server)
    partitioned_tables_regexp_1 =
      ~r/ALTER TABLE ONLY [\w_\.]+ ATTACH PARTITION (?<partitioned_table>[\w_\.]+)/

    partitioned_tables_1 =
      for [partitioned_table | _] <-
            Regex.scan(partitioned_tables_regexp_1, sql, capture: ["partitioned_table"]),
          do: partitioned_table

    # Earlier versions use an inline PARTITION OF
    partitioned_tables_regexp_2 =
      ~r/-- Name: (?<partitioned_table>[\w_\.]+); Type: TABLE\n\n[^;]+?PARTITION OF [\w_\.]+\n[^;]+?;/m

    partitioned_tables_2 =
      for [partitioned_table | _] <-
            Regex.scan(partitioned_tables_regexp_2, sql, capture: ["partitioned_table"]),
          do: partitioned_table

    partitioned_tables = partitioned_tables_1 ++ partitioned_tables_2

    partitioned_tables
    |> Enum.reduce(sql, fn partitioned_table, contents_acc ->
      partitioned_table_name_only =
        case String.split(partitioned_table, ".") do
          [_partitioned_schema_name, partitioned_table_name_only] -> partitioned_table_name_only
          [partitioned_table_name_only] -> partitioned_table_name_only
        end

      temp_contents_acc =
        contents_acc
        |> String.replace(~r/-- Name: #{partitioned_table_name_only}; Type: TABLE.*/m, "")
        |> String.replace(~r/^CREATE TABLE ([\w_]+\.)?#{partitioned_table} [^;]+;\n/m, "")
        |> String.replace(
          ~r/ALTER TABLE ONLY ([\w_\.]+) ATTACH PARTITION ([\w_]+\.)?#{partitioned_table}[^;]+;/m,
          ""
        )
        |> String.replace(
          ~r/ALTER TABLE ONLY ([\w_]+\.)?#{partitioned_table_name_only}[^;]+;/,
          ""
        )
        |> String.replace(~r/-- Name: #{partitioned_table} [^;]+; Type: DEFAULT/, "")

      index_regexp =
        ~r/CREATE (UNIQUE )?INDEX (?<partitioned_table_index>[\w_]+) ON ([\w_]+\.)?#{partitioned_table_name_only}[^;]+;/m

      partitioned_table_indexes =
        for [partitioned_table_index | _] <-
              Regex.scan(index_regexp, temp_contents_acc, capture: ["partitioned_table_index"]),
            do: partitioned_table_index

      partitioned_table_indexes
      |> Enum.reduce(temp_contents_acc, fn partitioned_table_index, scan_acc ->
        scan_acc
        |> String.replace(~r/-- Name: #{partitioned_table_index}; Type: INDEX ATTACH.*/m, "")
        |> String.replace(~r/-- Name: #{partitioned_table_index}; Type: INDEX.*/m, "")
        |> String.replace(~r/-- Name: #{partitioned_table_index}; Type: TABLE ATTACH.*/m, "")
        |> String.replace(
          ~r/ALTER INDEX ([\w_\.]+) ATTACH PARTITION ([\w_]+\.)?#{partitioned_table_index};/,
          ""
        )
      end)
      |> String.replace(index_regexp, "")
      |> String.replace(
        ~r/-- Name: ([\w_]+\.)?#{partitioned_table_name_only}_pkey; Type: INDEX ATTACH\n+[^;]+?ATTACH PARTITION ([\w_]+\.)?#{partitioned_table_name_only}_pkey;/m,
        ""
      )
    end)
  end

  defp remove_partitioned_tables(sql, _disabled), do: sql

  defp allow_restoring_postgres_11_output_on_postgres_10(sql, true = _enabled) do
    sql
    |> String.replace(~r/CREATE INDEX ([\w_]+) ON ONLY/, "CREATE INDEX \\1 ON")
  end

  defp allow_restoring_postgres_11_output_on_postgres_10(sql, _disabled), do: sql

  # Cleanup of schema_migrations values to prevent merge conflicts:
  # - sorts all values chronological
  # - places the comma's in front of each value (except for the first)
  # - places the semicolon on a separate last line
  defp order_schema_migrations_values(sql, true = _enabled) do
    # Read all schema_migrations values from the dump.
    migrations_values_regex =
      ~r/INSERT INTO public\."schema_migrations" \(version\) VALUES \(\'?(?<version>\d{8,14})\'?\)[,;]\n/m

    values =
      Regex.scan(migrations_values_regex, sql, capture: :all_but_first)
      |> List.flatten()
      |> Enum.sort()

    sql =
      sql
      |> String.replace(~r/INSERT INTO public\."schema_migrations".*;$/m, "")

    values = Enum.map(values, &"(#{&1})")

    sql <>
      "INSERT INTO public.\"schema_migrations\" (version) VALUES\n #{Enum.join(values, "\n,")}\n;\n"
  end

  defp order_schema_migrations_values(sql, _disabled), do: sql

  defp format_error(%ValidationError{keys_path: [], message: message}) do
    "invalid configuration given to StructureSqlFormatter.format/2, " <> message
  end

  defp format_error(%ValidationError{keys_path: keys_path, message: message}) do
    "invalid configuration given to StructureSqlFormatter.format/2 for key #{inspect(keys_path)}, " <>
      message
  end
end
