defmodule Kanta.Translations.Locales do
  alias Kanta.Cache
  alias Kanta.Repo

  alias Kanta.Translations.Locale

  alias Kanta.Translations.Locale.Utils.LocaleCodeMapper
  alias Kanta.Translations.Locale.Services.LocaleTranslationProgress

  @cache_prefix "locale_"
  @ttl :timer.seconds(3600)

  def list_locales do
    Repo.get_repo().all(Locale)
  end

  def get_locale(id) do
    Repo.get_repo().get(Locale, id)
  end

  def get_locale_translation_progress(locale_id) do
    LocaleTranslationProgress.call(locale_id)
  end

  def get_locale_by(params) do
    cache_key = @cache_prefix <> URI.encode_query(params)

    case Cache.get(cache_key) do
      nil ->
        case Repo.get_repo().get_by(Locale, params) do
          %Locale{} = locale ->
            Cache.put(cache_key, locale, ttl: @ttl)

            locale

          _ ->
            :not_found
        end

      cached_locale ->
        cached_locale
    end
  end

  def get_or_create_locale_by(params) do
    case get_locale_by(params) do
      %Locale{} = locale ->
        locale

      :not_found ->
        iso_code = params[:iso639_code]

        create_locale!(%{
          "iso639_code" => iso_code,
          "name" => LocaleCodeMapper.get_name(iso_code),
          "native_name" => LocaleCodeMapper.get_native_name(iso_code),
          "family" => LocaleCodeMapper.get_family(iso_code),
          "wiki_url" => LocaleCodeMapper.get_wiki_url(iso_code),
          "colors" => LocaleCodeMapper.get_colors(iso_code)
        })
    end
  end

  defp create_locale!(attrs) do
    %Locale{}
    |> Locale.changeset(attrs)
    |> Kanta.Repo.get_repo().insert!()
  end
end
