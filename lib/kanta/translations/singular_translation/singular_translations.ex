defmodule Kanta.Translations.SingularTranslations do
  alias Kanta.Cache
  alias Kanta.Repo

  alias Kanta.Translations.{Contexts, Locales, Domains, SingularTranslation}

  @cache_prefix "singular_translation_"
  @ttl :timer.seconds(3600 * 12)

  def get_singular_translation_by(params) do
    cache_key = @cache_prefix <> URI.encode_query(params)

    case Cache.get(cache_key) do
      nil ->
        case Repo.get_repo().get_by(SingularTranslation, params) do
          %SingularTranslation{} = translation ->
            Cache.put(cache_key, translation, ttl: @ttl)

            translation

          _ ->
            :not_found
        end

      cached_translation ->
        cached_translation
    end
  end

  def create_singular_translation(attrs) do
    locale = Locales.get_or_create_locale_by(name: attrs["locale"])
    domain = Domains.get_or_create_domain_by(name: attrs["domain"])
    context = Contexts.get_or_create_context_by(name: attrs["context"])

    %SingularTranslation{}
    |> SingularTranslation.changeset(%{
      msgid: attrs["msgid"],
      previous_text: attrs["previous_text"],
      text: attrs["text"],
      locale_id: locale.id,
      domain_id: domain.id,
      context_id: context.id
    })
    |> Repo.get_repo().insert()
  end

  def update_singular_translation(id, attrs) do
    repo = Repo.get_repo()

    case repo.get(SingularTranslation, id) do
      %SingularTranslation{} = singular_translation ->
        SingularTranslation.changeset(singular_translation, attrs)
        |> repo.update()
        |> case do
          {:ok, singular_translation} ->
            Cache.put(
              @cache_prefix <>
                URI.encode_query(
                  locale_id: singular_translation.locale_id,
                  message_id: singular_translation.message_id
                ),
              singular_translation,
              ttl: @ttl
            )

            {:ok, singular_translation}

          error ->
            error
        end

      nil ->
        :error
    end
  end
end
