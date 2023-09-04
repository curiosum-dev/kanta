import Config

config :kanta, Kanta.Cache,
  primary: [
    gc_interval: :timer.hours(24),
    backend: :shards
  ]

config :phoenix, :json_library, Jason
config :phoenix, :stacktrace_depth, 20

config :logger, level: :warning
config :logger, :console, format: "[$level] $message\n"

if config_env() == :dev do
  config :esbuild,
    version: "0.14.41",
    default: [
      args: ~w(js/app.js --bundle --target=es2020 --outdir=../dist/js),
      cd: Path.expand("../assets", __DIR__),
      env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
    ]

  config :tailwind,
    version: "3.2.4",
    default: [
      args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../dist/css/app.css
    ),
      cd: Path.expand("../assets", __DIR__)
    ]
end
