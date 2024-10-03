defmodule Kanta.Migrations.SQLite3.V02 do
  @moduledoc """
  Kanta V2 Migrations
  """

  use Ecto.Migration
  alias Kanta.Utils.Colors

  @kanta_application_sources "kanta_application_sources"
  @kanta_messages "kanta_messages"

  def up(opts) do
    [
      &up_application_sources/1,
      &up_kanta_messages/1
    ]
    |> Enum.each(&apply(&1, [opts]))
  end

  def down(opts) do
    [
      &down_application_sources/1,
      &down_kanta_messages/1
    ]
    |> Enum.each(&apply(&1, [opts]))
  end

  def up_application_sources(_opts) do
    create_if_not_exists table(@kanta_application_sources) do
      add(:name, :string)
      add(:description, :text)
      add(:color, :string, null: false, default: Colors.default_color())
      timestamps()
    end

    create_if_not_exists unique_index(@kanta_application_sources, [:name])
  end

  def up_kanta_messages(_opts) do
    alter table(@kanta_messages) do
      add(:application_source_id, references(@kanta_application_sources), null: true)
    end

    drop unique_index(@kanta_messages, [:context_id, :domain_id, :msgid])

    create_if_not_exists unique_index(
                           @kanta_messages,
                           [
                             :application_source_id,
                             :context_id,
                             :domain_id,
                             :msgid
                           ]
                         )
  end

  def down_application_sources(_opts) do
    drop table(@kanta_application_sources)
  end

  def down_kanta_messages(_opts) do
    drop unique_index(
           @kanta_messages,
           [
             :application_source_id,
             :context_id,
             :domain_id,
             :msgid
           ]
         )

    create_if_not_exists unique_index(@kanta_messages, [:context_id, :domain_id, :msgid])

    alter table(@kanta_messages) do
      remove(:application_source_id)
    end
  end
end
