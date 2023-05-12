defmodule Kanta.MixProject do
  use Mix.Project

  def project do
    [
      app: :kanta,
      description: "User-friendly translations manager for Elixir/Phoenix projects.",
      package: package(),
      version: "0.0.1-rc1",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Kanta.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:gettext,
       git: "git@github.com:bamorim/gettext.git", branch: "runtime-gettext", only: [:dev, :test]},
      {:expo, "~> 0.3.0"},
      {:ecto, "~> 3.9"},
      {:ecto_sql, "~> 3.9"},
      {:phoenix, "~> 1.7.0"},
      {:jason, "~> 1.0"},
      {:phoenix_live_view, "~> 0.18"},
      {:phoenix_view, "~> 2.0"},
      {:esbuild, "~> 0.5", only: :dev},
      {:tailwind, "~> 0.1", runtime: Mix.env() == :dev},
      {:lucide_live_view, "~> 0.1.0"},
      {:nebulex, "~> 2.4"},
      {:decorator, "~> 1.4"},
      {:shards, "~> 1.0"},
      {:tesla, "~> 1.4"},
      {:finch, "~> 0.15"},
      {:scrivener, "~> 2.0"},
      {:scrivener_ecto, "~> 2.0"},
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
