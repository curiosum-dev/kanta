defmodule Kanta.Migrations do
  use Ecto.Migration

  @kanta_locales "kanta_locales"
  @kanta_domains "kanta_domains"
  @kanta_singular_translations "kanta_singular_translations"

  def up do
    up_locales()
    up_domains()
    up_translations()
  end

  def down do
    down_locales()
    down_domains()
    down_translations()
  end

  defp up_locales do
    create table(@kanta_locales) do
      add(:name, :string)
    end

    create unique_index(@kanta_locales, [:name])
  end

  defp up_domains do
    create table(@kanta_domains) do
      add(:name, :string)
    end

    create unique_index(@kanta_domains, [:name])
  end

  defp up_translations do
    create table(@kanta_singular_translations) do
      add(:msgid, :string)
      add(:msgctxt, :string, null: true)
      add(:previous_text, :string)
      add(:text, :string, null: true)
      add(:locale_id, references(@kanta_locales))
      add(:domain_id, references(@kanta_domains), null: true)
    end

    create unique_index(@kanta_singular_translations, [:locale_id, :domain_id, :msgid, :msgctxt])

    create unique_index(@kanta_singular_translations, [:locale_id, :domain_id, :msgid],
             where: "msgctxt IS NULL"
           )
  end

  defp down_locales do
    drop table(@kanta_locales)
  end

  defp down_domains do
    drop table(@kanta_domains)
  end

  defp down_translations do
    drop table(@kanta_singular_translations)
  end
end
