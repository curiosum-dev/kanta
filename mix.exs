defmodule Kanta.MixProject do
  use Mix.Project

  def project do
    [
      app: :kanta,
      description: "User-friendly translations manager for Elixir/Phoenix projects.",
      package: package(),
      version: "0.4.0",
      elixir: "~> 1.14",
      elixirc_options: [
        warnings_as_errors: true
      ],
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: dialyzer(),
      docs: [
        extras: ["docs/how-to-write-plugins.md"],
        assets: "docs/assets",
        main: "Kanta"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:uri_query, :logger],
      mod: {Kanta.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:expo, "~> 0.3"},
      {:ecto, "~> 3.12"},
      {:ecto_sql, "~> 3.12"},
      {:phoenix, "~> 1.7.0"},
      {:phoenix_view, "~> 2.0"},
      {:phoenix_live_view, "~> 0.20"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_html_helpers, "~> 1.0"},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:jason, "~> 1.0"},
      {:nebulex, "~> 2.5"},
      {:shards, "~> 1.0"},
      {:scrivener, "~> 2.0"},
      {:scrivener_ecto, "~> 2.0"},
      {:uri_query, "~> 0.2"},
      # DEV
      {:versioce, "~> 2.0.0"},
      {:git_cli, "~> 0.3.0"},
      {:esbuild, "~> 0.7", only: :dev},
      {:credo, "~> 1.7.7", only: [:dev, :test], runtime: false},
      {:mix_audit, "~> 2.0", only: [:dev, :test], runtime: false},
      {:gettext, github: "ravensiris/gettext", branch: "runtime-gettext", only: [:dev, :test]},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "cmd --cd assets npm install", "assets.build"],
      "assets.build": [
        "esbuild default --minify",
        "tailwind default --minify"
      ]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/curiosum-dev/kanta"},
      files: ~w(lib priv dist CHANGELOG.md LICENSE.md mix.exs README.md)
    ]
  end

  defp dialyzer do
    [
      plt_file:
        {:no_warn, ".dialyzer/elixir-#{System.version()}-erlang-otp-#{System.otp_release()}.plt"}
    ]
  end
end
