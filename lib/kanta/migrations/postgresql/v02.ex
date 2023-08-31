defmodule Kanta.Migrations.Postgresql.V02 do
  @moduledoc """
  Kanta V2 Migrations
  """

  use Ecto.Migration

  @default_prefix "public"
  @kanta_singular_translations "kanta_singular_translations"
  @kanta_plural_translations "kanta_plural_translations"

  def up(opts) do
    Kanta.Migration.up(version: 1)
    up_fuzzy_search(opts)
  end

  def down(opts) do
    down_fuzzy_search(opts)
    Kanta.Migration.down(version: 1)
  end

  def up_fuzzy_search(opts) do
    prefix = Map.get(opts, :prefix, @default_prefix)

    [@kanta_plural_translations, @kanta_singular_translations]
    |> Enum.each(fn table_name ->
      execute """
        ALTER TABLE #{prefix}.#{table_name}
          ADD COLUMN IF NOT EXISTS searchable tsvector
          GENERATED ALWAYS AS (
            setweight(to_tsvector('simple', coalesce(translated_text, '')), 'A')
          ) STORED;
      """

      execute """
        CREATE INDEX IF NOT EXISTS #{table_name}_searchable_idx ON #{prefix}.#{table_name} USING gin(searchable);
      """
    end)

    execute("CREATE EXTENSION IF NOT EXISTS unaccent;")
  end

  def down_fuzzy_search(_opts) do
    execute("DROP EXTENSION IF EXISTS unaccent;")
  end
end
