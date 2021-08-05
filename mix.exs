defmodule Kanta.MixProject do
  use Mix.Project

  def project do
    [
      app: :kanta,
      name: "Kanta",
      version: "0.1.0",
      elixir: "~> 1.12.1",
      start_permanent: Mix.env() == :prod,
      elixirc_options: [warnings_as_errors: true],
      deps: deps(),
      aliases: [
        ci: [
          "format --check-formatted",
          "test",
          "credo --strict"
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false}
    ]
  end
end
