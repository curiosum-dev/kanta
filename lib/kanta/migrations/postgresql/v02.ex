defmodule Kanta.Migrations.Postgresql.V02 do
  @moduledoc """
  Kanta V2 Migrations
  """

  use Ecto.Migration

  @default_prefix "public"
  @kanta_messages "kanta_messages"

  def up(opts) do
    Kanta.Migration.up(version: 1)
    up_fuzzy_search(opts)
  end

  def down(opts) do
    down_fuzzy_search(opts)
    Kanta.Migration.down(version: 1)
  end

  @doc """
  Extensions and indices are necessary for &Kanta.Query.search_query/2,
  that uses combination of ILIKE %?% and Levenshtein distance to provide more accurate results.

  GIN is for trigram-indexed ILIKE search.
  SOUNDEX drastically reduces the number of rows on which we apply expensive Levenshtein distance operation.
  """
  def up_fuzzy_search(opts) do
    prefix = Map.get(opts, :prefix, @default_prefix)

    execute("CREATE EXTENSION IF NOT EXISTS pg_trgm;")
    execute("CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;")

    execute """
      CREATE INDEX IF NOT EXISTS #{@kanta_messages}_msgid_gin_idx ON #{prefix}.#{@kanta_messages} USING gin(msgid gin_trgm_ops);
    """

    execute """
      CREATE INDEX IF NOT EXISTS #{@kanta_messages}_msgid_soundex_idx ON #{prefix}.#{@kanta_messages} (soundex(msgid));
    """
  end

  def down_fuzzy_search(_opts) do
    execute("DROP INDEX IF EXISTS #{@kanta_messages}_msgid_soundex_idx;")
    execute("DROP INDEX IF EXISTS #{@kanta_messages}_msgid_gin_idx;")

    execute("DROP EXTENSION IF EXISTS fuzzystrmatch;")
    execute("DROP EXTENSION IF EXISTS pg_trgm;")
  end
end
