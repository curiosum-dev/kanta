# kanta/lib/kanta/migrations/postgresql/v05.ex
defmodule Kanta.Migrations.Postgresql.V05 do
  @moduledoc """
  Kanta PostgreSQL V5 Migration

  This module delegates to the Common.V05 migration, which:
  - Defines a new simplified schema with kanta_plurals and kanta_singulars tables
  - Renames domain/context tables to kanta_domain_metadata and kanta_context_metadata
  - Migrates data from the old schema using SQL INSERT INTO...SELECT
  - Drops the old tables after successful migration
  """
  use Ecto.Migration

  # This PostgreSQL migration delegates all work to the Common module
  # but reserves the space for potential PostgreSQL-specific logic if needed in the future.

  def up(opts) do
    IO.puts("PostgreSQL V05: Delegating to Common.V1Denormalized")
    Kanta.Migrations.Common.V1Denormalized.up(opts)
  end

  def down(opts) do
    IO.puts("PostgreSQL V05: Delegating to Common.V1Denormalized")
    Kanta.Migrations.Common.V1Denormalized.down(opts)
  end
end
