# Kanta

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `kanta` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:kanta, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/kanta>.

## Integrating with your application

### Add configuration

Add to `config/config.exs` file:

```elixir
# config/config.exs
config :kanta,
  ecto_repo: BetterGettext.Repo
```

Ecto repo is used for translations persistency.

### Create migration

Create migration with

```bash
mix ecto.gen.migration add_kanta_translations_table
```

Open the generated migration file and set up `up` and `down` functions:

```elixir
defmodule MyApp.Repo.Migrations.AddKantaTranslationsTable do
  use Ecto.Migration

  def up do
    Kanta.Migrations.up()
  end

  def down do
    Kanta.Migrations.down()
  end
end
```

And run

```bash
mix ecto.migrate
```

### Add caching process to supervision tree

Add `Kanta.Cache` to your apps supervision tree:

```elixir
# lib/my_app/application.ex
children = [
  # ... rest ...
  Kanta.Cache
]

opts = [strategy: :one_for_one, name: MyApp.Supervisor]
Supervisor.start_link(children, opts)
```

### Set up Kanta gettext repo

The last step is to set up Kanta's gettext repo:

```elixir
# lib/my_app_web/gettext.ex
use Gettext,
  otp_app: :my_app,
  repo: Kanta.GettextRepo
```
