# StructureSqlFormatter

Ever been annoyed at a constantly changing `priv/repo/structure.sql` file when using Ecto and Postgres?

Spent hours trying to decipher why that one team member keeps changing the file?

This library is here to help!

It cleans away all the unnecessary output in the file every time you run `mix format`. This helps avoid merge conflicts, as well as increase readability.

I took inspiration from [activerecord-clean-db-structure](https://github.com/lfittl/activerecord-clean-db-structure) and reimplemented the logic in Elixir.

## Installation

The package can be installed by adding `structure_sql_formatter` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:structure_sql_formatter, "~> 1.0.0", only: :dev}
  ]
end
```

## Usage

Uses Elixir formatter [plugin
system](https://hexdocs.pm/mix/1.16.3/Mix.Tasks.Format.html#module-plugins).

```elixir
# .formatter.exs
[
  plugins: [StructureSqlFormatter],
  # See `StructureSqlFormatter.Options` for all available options.
  structure_sql_formatter_opts: [
    order_schema_migrations_values: true
  ],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}", "priv/repo/structure.sql"]
]
```

Running `mix format` is going to take over as usual from here.
