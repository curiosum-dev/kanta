defmodule Kanta.Migrations.Postgresql.V01 do
  @moduledoc """
  Kanta V1 Migrations
  """

  use Ecto.Migration

  @kanta_locales "kanta_locales"
  @kanta_domains "kanta_domains"
  @kanta_contexts "kanta_contexts"
  @kanta_messages "kanta_messages"
  @kanta_singular_translations "kanta_singular_translations"
  @kanta_plural_translations "kanta_plural_translations"

  def up(_opts) do
    up_locales()
    up_contexts()
    up_domains()
    up_messages()
    up_singular_translations()
    up_plural_translations()
  end

  def down(_opts) do
    down_locales()
    down_domains()
    down_contexts()
    down_messages()
    down_singular_translations()
    down_plural_translations()
  end

  defp up_locales do
    create_if_not_exists table(@kanta_locales) do
      add(:iso639_code, :string)
      add(:name, :string)
      add(:native_name, :string)
      add(:family, :string)
      add(:wiki_url, :string)
      add(:colors, {:array, :string})
      add(:plurals_header, :string)
      timestamps()
    end

    create_if_not_exists unique_index(@kanta_locales, [:iso639_code])
  end

  defp up_domains do
    create_if_not_exists table(@kanta_domains) do
      add(:name, :string)
      add(:description, :text)
      add(:color, :string, null: false, default: "#7E37D8")
      timestamps()
    end

    create_if_not_exists unique_index(@kanta_domains, [:name])
  end

  defp up_contexts do
    create_if_not_exists table(@kanta_contexts) do
      add(:name, :string)
      add(:description, :text)
      add(:color, :string, null: false, default: "#7E37D8")
      timestamps()
    end

    create_if_not_exists unique_index(@kanta_contexts, [:name])
  end

  defp up_messages do
    create_if_not_exists_message_type_query = "
      DO $$ BEGIN
          CREATE TYPE gettext_message_type AS ENUM ('singular', 'plural');
      EXCEPTION
          WHEN duplicate_object THEN null;
      END $$
    "

    drop_message_type_query = "DROP TYPE gettext_message_type"
    execute(create_if_not_exists_message_type_query, drop_message_type_query)

    create_if_not_exists table(@kanta_messages) do
      add(:msgid, :text)
      add(:message_type, :gettext_message_type, null: false)
      add(:domain_id, references(@kanta_domains), null: true)
      add(:context_id, references(@kanta_contexts), null: true)
      timestamps()
    end

    execute """
      ALTER TABLE #{prefix()}.#{@kanta_messages}
        ADD COLUMN searchable tsvector
        GENERATED ALWAYS AS (
          setweight(to_tsvector('english', coalesce(msgid, '')), 'A')
        ) STORED;
    """

    execute """
      CREATE INDEX #{@kanta_messages}_searchable_idx ON #{prefix()}.#{@kanta_messages} USING gin(searchable);
    """

    create_if_not_exists unique_index(@kanta_messages, [:context_id, :domain_id, :msgid])
  end

  defp up_singular_translations do
    create_if_not_exists table(@kanta_singular_translations) do
      add(:original_text, :text)
      add(:translated_text, :text, null: true)
      add(:locale_id, references(@kanta_locales))
      add(:message_id, references(@kanta_messages))
      timestamps()
    end

    create_if_not_exists unique_index(@kanta_singular_translations, [:locale_id, :message_id])
  end

  defp up_plural_translations do
    create_if_not_exists table(@kanta_plural_translations) do
      add(:nplural_index, :integer)
      add(:original_text, :text)
      add(:translated_text, :text, null: true)
      add(:locale_id, references(@kanta_locales))
      add(:message_id, references(@kanta_messages))
      timestamps()
    end

    create_if_not_exists unique_index(@kanta_plural_translations, [
                           :locale_id,
                           :message_id,
                           :nplural_index
                         ])
  end

  defp down_locales do
    drop table(@kanta_locales)
  end

  defp down_domains do
    drop table(@kanta_domains)
  end

  defp down_contexts do
    drop table(@kanta_contexts)
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
