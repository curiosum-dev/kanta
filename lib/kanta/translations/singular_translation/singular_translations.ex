defmodule Kanta.Translations.SingularTranslations do
  use Nebulex.Caching

  alias Kanta.Cache
  alias Kanta.Repo

  alias Kanta.Translations.{Locales, Domains, SingularTranslation, SingularTranslationQueries}

  @ttl :timer.hours(12)

  def create_singular_translation(attrs) do
    locale = Locales.get_or_create_locale_by_name(attrs["locale"])
    domain = Domains.get_or_create_domain_by_name(attrs["domain"])

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

  @decorate cacheable(
              cache: Cache,
              key: {SingularTranslation, params["msgid"]},
              opts: [ttl: @ttl]
            )
  def get_singular_translation(params) do
    SingularTranslationQueries.filter(
      msgid: params["msgid"],
      msgctxt: params["msgctxt"]
    )
    |> SingularTranslationQueries.filter_by_locale(params["locale"])
    |> SingularTranslationQueries.filter_by_domain(params["domain"])
    |> Repo.get_repo().one()
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

  @decorate cacheable(cache: Cache, key: Locale, opts: [ttl: @ttl])
  def list_singular_translations(filters \\ []) do
    repo = Repo.get_repo()

    SingularTranslationQueries.filter(filters)
    |> repo.all()
    |> repo.preload([:locale, :domain])
  end
end
