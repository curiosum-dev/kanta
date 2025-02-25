defmodule Kanta.Migrations.Postgresql.V04 do
  @moduledoc """
  Kanta PostgreSQL V4 Migrations
  """

  use Ecto.Migration

  @doc """
  Ensure that the `default` context exists.
  """
  def up(_opts) do
    # Insert the 'default' context if it doesn't exist
    execute("""
    INSERT INTO kanta_contexts (name, inserted_at, updated_at)
    VALUES ('default', NOW(), NOW())
    ON CONFLICT (name) DO NOTHING;
    """)

    flush()

    # Update messages with null context_id to use the 'default' context's ID
    execute("""
    UPDATE kanta_messages
    SET context_id = (SELECT id FROM kanta_contexts WHERE name = 'default')
    WHERE context_id IS NULL;
    """)
  end

  def down(_opts), do: nil
end
