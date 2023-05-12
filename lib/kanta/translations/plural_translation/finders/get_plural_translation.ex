defmodule Kanta.Translations.PluralTranslations.Finders.GetPluralTranslation do
  use Kanta.Query,
    module: Kanta.Translations.PluralTranslation,
    binding: :plural_translation

  alias Kanta.Cache
  alias Kanta.Translations.PluralTranslation

  def find(params \\ []) do
    cache_key = Cache.generate_cache_key("plural_translation", params)

    with {:error, _, :not_cached} <- find_in_cache(cache_key),
         {:ok, %PluralTranslation{} = plural_translation} <- find_in_database(params) do
      Cache.put(cache_key, plural_translation)

      {:ok, plural_translation}
    else
      {:ok, %PluralTranslation{} = plural_translation} -> {:ok, plural_translation}
      {:error, _, :not_found} -> {:error, :plural_translation, :not_found}
    end
  end

  defp find_in_cache(cache_key) do
    case Cache.get(cache_key) do
      nil ->
        {:error, :plural_translation, :not_cached}

      cached_plural_translation ->
        {:ok, cached_plural_translation}
    end
  end

  defp find_in_database(params) do
    base()
    |> filter_query(params[:filter])
    |> search_query(params[:search])
    |> preload_resources(params[:preloads] || [])
    |> one()
    |> case do
      %PluralTranslation{} = plural_translation -> {:ok, plural_translation}
      _ -> {:error, :plural_translation, :not_found}
    end
  end
end
