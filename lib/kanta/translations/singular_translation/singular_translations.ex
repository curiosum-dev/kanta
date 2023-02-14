defmodule Kanta.Translations.SingularTranslations do
  use Nebulex.Caching

  alias Kanta.Cache
  alias Kanta.Repo

  alias Kanta.Translations.{Locales, Domains, SingularTranslation, SingularTranslationQueries}

  @ttl :timer.hours(12)

  def list_singular_translations(params) do
    repo = Repo.get_repo()

    SingularTranslationQueries.base()
    |> SingularTranslationQueries.filter_query(params["filter"])
    |> repo.all()
    |> repo.preload([:locale, :domain])
  end

  @decorate cacheable(
              cache: Cache,
              key: {SingularTranslation, params},
              opts: [ttl: @ttl]
            )
  def get_singular_translation_by(params) do
    SingularTranslationQueries.base()
    |> SingularTranslationQueries.filter_query(params["filter"])
    |> Repo.get_repo().one()
  end

  def create_singular_translation(attrs) do
    locale = Locales.get_or_create_locale_by(%{"filter" => %{"name" => attrs["locale"]}})
    domain = Domains.get_or_create_domain_by(%{"filter" => %{"name" => attrs["domain"]}})

    %SingularTranslation{}
    |> SingularTranslation.changeset(%{
      msgctxt: attrs["msgctxt"],
      msgid: attrs["msgid"],
      previous_text: attrs["previous_text"],
      text: attrs["text"],
      locale_id: locale.id,
      domain_id: domain.id
    })
    |> Repo.get_repo().insert()
  end

  def update_singular_translation(id, attrs) do
    repo = Repo.get_repo()

    case repo.get(SingularTranslation, id) do
      %SingularTranslation{} = singular_translation ->
        SingularTranslation.changeset(singular_translation, %{
          translated_text: attrs["translated_text"]
        })
        |> repo.update()

      nil ->
        :error
    end
  end

  @decorate cache_evict(cache: Cache, key: {SingularTranslation, id})
  def delete_singular_translation(id) do
    repo = Repo.get_repo()

    with %SingularTranslation{} = translation <- repo.get(id) do
      repo.delete(translation)
    else
      nil -> :not_found
    end
  end
end
