defmodule Kanta.Migrations do
  use Ecto.Migration

  @kanta_locales "kanta_locales"
  @kanta_domains "kanta_domains"
  @kanta_messages "kanta_messages"
  @kanta_singular_translations "kanta_singular_translations"
  @kanta_plural_translations "kanta_plural_translations"

  def up do
    up_locales()
    up_domains()
    up_messages()
    up_singular_translations()
    up_plural_translations()
  end

  def down do
    down_locales()
    down_domains()
    down_messages()
    down_singular_translations()
    down_plural_translations()
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

  defp up_messages do
    create table(@kanta_messages) do
      add(:msgid, :string)
      add(:msgctxt, :string, null: true)
      add(:domain_id, references(@kanta_domains), null: true)
    end

    create unique_index(@kanta_messages, [:domain_id, :msgid])
  end

  defp up_singular_translations do
    create table(@kanta_singular_translations) do
      add(:original_text, :string)
      add(:translated_text, :string, null: true)
      add(:locale_id, references(@kanta_locales))
      add(:message_id, references(@kanta_messages))
    end

    create unique_index(@kanta_singular_translations, [:locale_id, :message_id])
  end

  defp up_plural_translations do
    create table(@kanta_plural_translations) do
      add(:nplural_index, :integer)
      add(:original_text, :string)
      add(:translated_text, :string, null: true)
      add(:locale_id, references(@kanta_locales))
      add(:message_id, references(@kanta_messages))
    end

    create unique_index(@kanta_plural_translations, [:locale_id, :message_id, :nplural_index])
  end

  defp down_locales do
    drop table(@kanta_locales)
  end

  defp down_domains do
    drop table(@kanta_domains)
  end

  defp down_messages do
    drop table(@kanta_messages)
  end

  defp down_singular_translations do
    drop table(@kanta_singular_translations)
  end

  defp down_plural_translations do
    drop table(@kanta_plural_translations)
  end
end
