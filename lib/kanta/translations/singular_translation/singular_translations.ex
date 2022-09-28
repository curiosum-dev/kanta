defmodule Kanta.Translations.SingularTranslations do
  alias Kanta.Translations.{Locales, Domains, SingularTranslation, SingularTranslationQueries}
  alias Kanta.Repo
  alias Kanta.EmbeddedSchemas.SingularTranslation, as: EmbeddedSingularTranslation

  def create_singular_translation(
        %EmbeddedSingularTranslation{
          locale: locale,
          domain: domain,
          msgid: msgid,
          original_text: original_text,
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
        original_text: original_text,
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
    |> Enum.map(fn %SingularTranslation{} = record ->
      %EmbeddedSingularTranslation{
        locale: record.locale.name,
        domain: record.domain.name,
        msgctxt: record.msgctxt,
        msgid: record.msgid,
        original_text: record.original_text,
        text: record.text
      }
    end)
  end
end
