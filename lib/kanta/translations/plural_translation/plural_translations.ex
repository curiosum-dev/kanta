defmodule Kanta.Translations.PluralTranslations do

  alias Kanta.Cache
  alias Kanta.Repo

  alias Kanta.Translations.{Locales, Domains, PluralTranslation, PluralTranslationQueries}

  def list_plural_translations(params) do
    repo = Repo.get_repo()

    PluralTranslationQueries.base()
    |> PluralTranslationQueries.filter_query(params["filter"])
    |> repo.all()
  end

  def get_plural_translation_by(params) do
    PluralTranslationQueries.base()
    |> PluralTranslationQueries.filter_query(params["filter"])
    |> Repo.get_repo().one()
  end

  def create_plural_translation(attrs) do
    locale = Locales.get_or_create_locale_by(%{"filter" => %{"name" => attrs["locale"]}})
    domain = Domains.get_or_create_domain_by(%{"filter" => %{"name" => attrs["domain"]}})

    %PluralTranslation{}
    |> PluralTranslation.changeset(%{
      msgctxt: attrs["msgctxt"],
      msgid: attrs["msgid"],
      previous_text: attrs["previous_text"],
      text: attrs["text"],
      locale_id: locale.id,
      domain_id: domain.id
    })
    |> Repo.get_repo().insert()
  end

  def update_plural_translation(id, attrs) do
    repo = Repo.get_repo()

    case repo.get(PluralTranslation, id) do
      %PluralTranslation{} = plural_translation ->
        PluralTranslation.changeset(plural_translation, %{
          translated_text: attrs["translated_text"]
        })
        |> repo.update()

      nil ->
        :error
    end
  end

  def delete_plural_translation(id) do
    repo = Repo.get_repo()

    with %PluralTranslation{} = translation <- repo.get(id) do
      repo.delete(translation)
    else
      nil -> :not_found
    end
  end
end
