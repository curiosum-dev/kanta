defmodule Kanta.Migrations.Postgresql.V05 do
  use Ecto.Migration

  def up(_) do
    create table("plurals") do
      add :locale, :string
      add :domain, :string, null: true
      add :msgctxt, :string, null: true
      add :msgid, :string
      add :msgid_plural, :string
      add :msgstr, :string
      add :plural_index, :integer
      add :msgstr_origin, :string
    end

    create unique_index(
             "plurals",
             [
               :locale,
               :domain,
               :msgctxt,
               :msgid,
               :msgid_plural,
               :plural_index
             ],
             nulls_distinct: false
           )

    create table("singulars") do
      add :locale, :string
      add :domain, :string, null: true
      add :msgctxt, :string, null: true
      add :msgid, :string
      add :msgstr, :string
      add :msgstr_origin, :string
    end

    create unique_index("singulars", [:locale, :domain, :msgctxt, :msgid], nulls_distinct: false)

    create table("domains") do
      add :name, :string, null: false
      add :description, :string
      add :color, :string
    end

    create unique_index("domains", [:name])

    create table("contexts") do
      add :name, :string, null: false
      add :description, :string, null: false
      add :color, :string, null: false
    end

    create unique_index("contexts", [:name])
  end

  def down(_) do
    drop table("singulars")
    drop table("plurals")
    drop table("contexts")
    drop table("domains")
    execute "DROP SCHEMA IF EXISTS kanta CASCADE"
  end
end
