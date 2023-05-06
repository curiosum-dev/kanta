defmodule Kanta.Translations.Locales do
  alias Kanta.Cache
  alias Kanta.Repo

  alias Kanta.Translations.Locale
  alias Kanta.Translations.LocaleQueries

  alias Kanta.Translations.Locale.Utils.LocaleCodeMapper
  alias Kanta.Translations.Locale.Services.LocaleTranslationProgress

  def list_locales do
    LocaleQueries.base()
    |> Repo.get_repo().all()
  end

  def get_locale(id) do
    Repo.get_repo().get(Locale, id)
  end

  def get_locale_translation_progress(locale_id) do
    LocaleTranslationProgress.call(locale_id)
  end

  def get_locale_by(params) do
    LocaleQueries.base()
    |> LocaleQueries.filter_query(params["filter"])
    |> Repo.get_repo().one()
  end

  def get_or_create_locale_by(params) do
    case get_locale_by(params) do
      %Locale{} = locale ->
        locale

      nil ->
        iso_code = params["filter"]["iso639_code"]

        create_locale!(
          Map.merge(params["filter"], %{
            "name" => LocaleCodeMapper.get_name(iso_code),
            "native_name" => LocaleCodeMapper.get_native_name(iso_code),
            "family" => LocaleCodeMapper.get_family(iso_code),
            "wiki_url" => LocaleCodeMapper.get_wiki_url(iso_code),
            "colors" => LocaleCodeMapper.get_colors(iso_code)
          })
        )
    end
  end

  defp create_locale!(attrs) do
    %Locale{}
    |> Locale.changeset(attrs)
    |> Kanta.Repo.get_repo().insert!()
  end
end
