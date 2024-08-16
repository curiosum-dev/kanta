defmodule Kanta.Migrations.Postgresql.V03 do
  @moduledoc """
  Kanta V3 Migrations
  """

  use Ecto.Migration

  def up(_opts) do
    Kanta.Migration.up(version: 2)

    execute(
      "INSERT INTO kanta_contexts (name,inserted_at,updated_at) VALUES('default', NOW(), NOW()) ON CONFLICT (name) DO NOTHING;"
    )

    execute("UPDATE kanta_messages SET context_id=1 WHERE context_id IS NULL;")
  end

  def down(_opts) do
    Kanta.Migration.down(version: 2)
  end
end
