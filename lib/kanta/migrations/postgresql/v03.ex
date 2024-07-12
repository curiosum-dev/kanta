defmodule Kanta.Migrations.Postgresql.V03 do
  @moduledoc """
  Kanta V3 Migrations
  """

  use Ecto.Migration
  alias Kanta.Translations
  alias Kanta.Translations.Context

  @default_prefix "public"
  @kanta_singular_translations "kanta_singular_translations"
  @kanta_plural_translations "kanta_plural_translations"

  def up(opts) do
    Kanta.Migration.up(version: 2)

    execute(
      "INSERT INTO kanta_contexts (name,inserted_at,updated_at) VALUES('default', NOW(), NOW()) ON CONFLICT (name) DO NOTHING;"
    )

    execute("UPDATE kanta_messages SET context_id=1 WHERE context_id IS NULL;")
  end

  def down(opts) do
    Kanta.Migration.down(version: 2)
  end
end
