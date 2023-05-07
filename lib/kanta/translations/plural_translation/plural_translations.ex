defmodule Kanta.Translations.PluralTranslations do
  import Ecto.Query, only: [from: 2]

  alias Kanta.Cache
  alias Kanta.Repo

  alias Kanta.Translations.{Contexts, Locales, Domains, PluralTranslation}

  @cache_prefix "plural_translation_"
  @ttl :timer.seconds(3600 * 12)

  def list_plural_translations_by([{:locale_id, locale_id}, {:message_id, message_id}]) do
    query =
      from(pt in PluralTranslation,
        where: pt.message_id == ^message_id,
        where: pt.locale_id == ^locale_id
      )

    Repo.get_repo().all(query)
  end

  def get_plural_translation_by(params) do
    cache_key = @cache_prefix <> URI.encode_query(params)

    case Cache.get(cache_key) do
      nil ->
        case Repo.get_repo().get_by(PluralTranslation, params) do
          %PluralTranslation{} = translation ->
            Cache.put(cache_key, translation, ttl: @ttl)

            translation

          _ ->
            :not_found
        end

      cached_translation ->
        cached_translation
    end
  end

  def create_plural_translation(attrs) do
    locale = Locales.get_or_create_locale_by(name: attrs["locale"])
    domain = Domains.get_or_create_domain_by(name: attrs["domain"])
    context = Contexts.get_or_create_context_by(name: attrs["context"])

    %PluralTranslation{}
    |> PluralTranslation.changeset(%{
      msgid: attrs["msgid"],
      previous_text: attrs["previous_text"],
      text: attrs["text"],
      locale_id: locale.id,
      domain_id: domain.id,
      context_id: context.id
    })
    |> Repo.get_repo().insert()
  end

  def update_plural_translation(id, attrs) do
    repo = Repo.get_repo()

    case repo.get(PluralTranslation, id) do
      %PluralTranslation{} = plural_translation ->
        PluralTranslation.changeset(plural_translation, attrs)
        |> repo.update()
        |> case do
          {:ok, plural_translation} ->
            Cache.put(
              @cache_prefix <>
                URI.encode_query(
                  locale_id: plural_translation.locale_id,
                  message_id: plural_translation.message_id,
                  nplural_index: plural_translation.nplural_index
                ),
              plural_translation,
              ttl: @ttl
            )

            {:ok, plural_translation}

          error ->
            error
        end

      nil ->
        :error
    end
  end
end
