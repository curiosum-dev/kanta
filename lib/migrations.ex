defmodule Kanta.Migrations do
  use Ecto.Migration

  @name "kanta_translations"

  def up do
    create table(@name) do
      add(:locale, :string)
      add(:msgid, :string)
      add(:domain, :string, null: true)
      add(:msgctxt, :string, null: true)
      add(:translated, :string)
    end

    create(unique_index(@name, [:locale, :msgid, :domain, :msgctxt]))
  end

  def down do
    drop(table(@name))
  end
end
