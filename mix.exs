defmodule Kanta.MixProject do
  use Mix.Project

  def project do
    [
      app: :kanta,
      description: "User-friendly translations manager for Elixir/Phoenix projects.",
      package: package(),
      version: "0.1.1",
      elixir: "~> 1.14",
      elixirc_options: [
        warnings_as_errors: true
      ],
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
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
      {:gettext,
       git: "git@github.com:bamorim/gettext.git", branch: "runtime-gettext", only: [:dev, :test]},
      {:expo, "~> 0.3"},
      {:ecto, "~> 3.10"},
      {:ecto_sql, "~> 3.10"},
      {:phoenix, "~> 1.7.0"},
      {:phoenix_live_view, "~> 0.18"},
      {:phoenix_view, "~> 2.0"},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:lucide_live_view, "~> 0.1.0"},
      {:jason, "~> 1.0"},
      {:nebulex, "~> 2.5"},
      {:shards, "~> 1.0"},
      {:tesla, "~> 1.4"},
      {:finch, "~> 0.16"},
      {:scrivener, "~> 2.0"},
      {:scrivener_ecto, "~> 2.0"},
      {:uri_query, "~> 0.1.1"},
      {:esbuild, "~> 0.7", only: :dev},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:mix_audit, "~> 2.0", only: [:dev, :test], runtime: false}
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
end
