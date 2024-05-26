defmodule StructureSqlFormatter.Options do
  @moduledoc false

  definition = [
    remove_trailing_whitespace: [
      type: :boolean,
      default: true,
      doc: """
      Remove trailing whitespace.
      """
    ],
    remove_version_specific_output: [
      type: :boolean,
      default: true,
      doc: """
      Don't output the postgres version used in the dump. Also remove some specific queries for different versions.
      """
    ],
    remove_useless_comment_lines: [
      type: :boolean,
      default: true,
      doc: """
      Remove `--` comments.
      """
    ],
    remove_pg_stat_statements_extension: [
      type: :boolean,
      default: true,
      doc: """
      Remove pg_stat_statements extension (its not relevant to the code).
      """
    ],
    remove_pg_buffercache_extension: [
      type: :boolean,
      default: true,
      doc: """
      Remove pg_buffercache extension (its not relevant to the code).
      """
    ],
    remove_comments_on_extensions: [
      type: :boolean,
      default: true,
      doc: """
      Remove `COMMENT ON EXTENSION` parts.
      """
    ],
    remove_useless_version_specific_parts_of_comments: [
      type: :boolean,
      default: true,
      doc: """
      Remove `Schema: xxx; Owner; yyy` parts.
      """
    ],
    reduce_noise_for_id_fields: [
      type: :boolean,
      default: false,
      doc: """
      Reduce noise for id fields by making them SERIAL instead of integer+sequence stuff.
      This is a bit optimistic, but works as long as you don't have an id field thats not a sequence/uuid.
      """
    ],
    remove_inherited_tables: [
      type: :boolean,
      default: false,
      doc: """
      Remove inherited tables.
      """
    ],
    remove_partitioned_tables: [
      type: :boolean,
      default: false,
      doc: """
      Remove partitioned tables.
      """
    ],
    allow_restoring_postgres_11_output_on_postgres_10: [
      type: :boolean,
      default: true,
      doc: """
      Makes dump from postgres 11 compatible for postgres 10.
      """
    ],
    order_schema_migrations_values: [
      type: :boolean,
      default: false,
      doc: """
      Cleanup of schema_migrations values to prevent merge conflicts:
      - sorts all values chronological
      - places the comma's in front of each value (except for the first)
      - places the semicolon on a separate last line
      """
    ]
  ]

  @definition NimbleOptions.new!(definition)

  def definition() do
    @definition
  end
end
