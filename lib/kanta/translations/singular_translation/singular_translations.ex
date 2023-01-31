defmodule Kanta.Translations.SingularTranslations do
  alias Kanta.Translations.{Locales, Domains, SingularTranslation, SingularTranslationQueries}
  alias Kanta.Repo
  alias Kanta.EmbeddedSchemas.SingularTranslation, as: EmbeddedSingularTranslation

  def create_singular_translation(
        %EmbeddedSingularTranslation{
          locale: locale,
          domain: domain,
          msgid: msgid,
          previous_text: previous_text,
          text: text
        } = translation
      ) do
    msgctxt = Map.get(translation, :msgctxt)

    locale_record = Locales.get_or_create_locale_by_name(locale)
    domain_record = Domains.get_or_create_domain_by_name(domain)

    %SingularTranslation{}
    |> SingularTranslation.create_changeset(
      %{
        msgctxt: msgctxt,
        msgid: msgid,
        previous_text: previous_text,
        text: text
      },
      locale_record,
      domain_record
    )
    |> Repo.get_repo().insert()
  end

  def get_singular_translation(
        %EmbeddedSingularTranslation{
          locale: locale,
          domain: domain,
          msgid: msgid
        } = translation
      ) do
    msgctxt = Map.get(translation, :msgctxt)

    SingularTranslationQueries.filter(
      msgid: msgid,
      msgctxt: msgctxt
    )
    |> SingularTranslationQueries.filter_by_locale(locale)
    |> SingularTranslationQueries.filter_by_domain(domain)
    |> Repo.get_repo().one()
  end

  def delete_singular_translation(%EmbeddedSingularTranslation{} = translation) do
    translation
    |> get_singular_translation()
    |> delete_singular_translation()
  end

  def delete_singular_translation(%SingularTranslation{} = singular_translation_record) do
    singular_translation_record
    |> Repo.get_repo().delete()
  end

  def delete_singular_translation(nil), do: nil

  def list_singular_translations(filters \\ []) do
    repo = Repo.get_repo()

    SingularTranslationQueries.filter(filters)
    |> repo.all()
    |> repo.preload([:locale, :domain])
    |> Enum.map(&into_embedded_singular_translation/1)
  end

  def list_singular_translations_with_text_not_null do
    repo = Repo.get_repo()

    SingularTranslationQueries.with_text_not_null()
    |> repo.all()
    |> repo.preload([:locale, :domain])
    |> Enum.map(&into_embedded_singular_translation/1)
  end

  defp into_embedded_singular_translation(%SingularTranslation{} = record) do
    %EmbeddedSingularTranslation{
      locale: record.locale.name,
      domain: record.domain.name,
      msgctxt: record.msgctxt,
      msgid: record.msgid,
      previous_text: record.previous_text,
      text: record.text
    }
  end
end
