defmodule StructureSqlFormatter.MixProject do
  use Mix.Project

  @version "1.0.2"
  @source_url "https://github.com/egze/structure_sql_formatter"

  def project do
    [
      app: :structure_sql_formatter,
      version: @version,
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs()
    ]
  end

  defp description do
    """
    StructureSqlFormatter is a plugin for Elixir Formatter that automatically removes unnecessary output from the structure.sql file.
    """
  end

  defp package do
    [
      files: [
        "lib",
        "LICENSE.md",
        "mix.exs",
        "README.md"
      ],
      maintainers: ["Aleksandr Lossenko"],
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => "https://github.com/egze/structure_sql_formatter"
      }
    ]
  end

  defp docs() do
    [
      main: "readme",
      name: "StructureSqlFormatter",
      canonical: "http://hexdocs.pm/structure_sql_formatter",
      source_url: @source_url,
      extras: ["README.md", "CHANGELOG.md", "LICENSE.md"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nimble_options, ">= 1.0.0"},

      # Dev/test dependencies.
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end
end
