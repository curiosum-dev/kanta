defmodule Kanta.Migrations.Postgresql.V04 do
  @moduledoc """
  Kanta V4 Migrations
  """

  use Ecto.Migration

  def up do
    Kanta.Migration.up(version: 3)

    execute(
      "INSERT INTO kanta_contexts (name,inserted_at,updated_at) VALUES('default', NOW(), NOW()) ON CONFLICT (name) DO NOTHING;"
    )

    execute("UPDATE kanta_messages SET context_id=1 WHERE context_id IS NULL;")
  end

  def down do
    execute("UPDATE kanta_messages SET context_id=NULL WHERE context_id=1;")

    execute(
      "DELETE FROM kanta_contexts WHERE name='default';"
    )
  end
end
