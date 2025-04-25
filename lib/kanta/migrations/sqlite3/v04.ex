# kanta/lib/kanta/migrations/sqlite3/v05.ex
defmodule Kanta.Migrations.SQLite3.V05 do
  @moduledoc """
  Kanta SQLite3 V5 Migration

  This module delegates to the Common.V05 migration, which:
  - Defines a new simplified schema with kanta_plurals and kanta_singulars tables
  - Renames domain/context tables to kanta_domain_metadata and kanta_context_metadata
  - Migrates data from the old schema using SQL INSERT INTO...SELECT
  - Drops the old tables after successful migration

  Note: This is the first SQLite3 migration after V03, as V04 was PostgreSQL-specific.
  """

  use Ecto.Migration

  @kant_messages "kanta_messages"

  # This SQLite3 migration delegates all work to the Common module
  # but reserves the space for potential SQLite3-specific logic if needed in the future.

  def up(opts) do
    IO.puts("SQLite3 V05: Delegating to Common.V05")
    # We're jumping from V03 to V05 in SQLite, as V04 was PG-specific
    Kanta.Migrations.Common.V1Denormalized.up(opts)
    drop_if_exists table(@kant_messages, prefix: prefix(opts))
  end

  def down(opts) do
    IO.puts("SQLite3 V05: Delegating to Common.V05")
    Kanta.Migrations.Common.V1Denormalized.down(opts)
  end

  # Helper to get prefix from opts
  defp prefix(opts), do: Map.get(opts, :prefix)
end
