defmodule Kanta.MixProject do
  use Mix.Project

  def project do
    [
      app: :kanta,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:gettext, git: "git@github.com:bamorim/gettext.git", branch: "runtime-gettext"},
      {:expo, "~> 0.1.0-beta.7"},
      {:ecto, ">= 3.0.0"},
      {:ecto_sql, ">= 3.0.0"},
      {:phoenix, ">= 1.6.0"},
      {:phoenix_live_view, ">= 0.17.0"}
    ]
  end
end
