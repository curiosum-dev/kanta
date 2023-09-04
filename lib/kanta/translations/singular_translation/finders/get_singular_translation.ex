defmodule Kanta.Translations.SingularTranslations.Finders.GetSingularTranslation do
  @moduledoc """
  Query module aka Finder responsible for finding singular translations
  """

  use Kanta.Query,
    module: Kanta.Translations.SingularTranslation,
    binding: :singular_translation

  alias Kanta.Cache
  alias Kanta.Translations.SingularTranslation

  def find(params \\ []) do
    cache_key = Cache.generate_cache_key("singular_translation", params)

    with {:error, _, :not_cached} <- find_in_cache(cache_key),
         {:ok, %SingularTranslation{} = singular_translation} <- find_in_database(params) do
      Cache.put(cache_key, singular_translation)

      {:ok, singular_translation}
    else
      {:ok, %SingularTranslation{} = singular_translation} -> {:ok, singular_translation}
      {:error, _, :not_found} -> {:error, :singular_translation, :not_found}
    end
  end

  defp find_in_cache(cache_key) do
    case Cache.get(cache_key) do
      nil ->
        {:error, :singular_translation, :not_cached}

      cached_singular_translation ->
        {:ok, cached_singular_translation}
    end
  end

  defp find_in_database(params) do
    base()
    |> filter_query(params[:filter])
    |> search_query(params[:search])
    |> preload_resources(params[:preloads] || [])
    |> one()
    |> case do
      %SingularTranslation{} = singular_translation -> {:ok, singular_translation}
      _ -> {:error, :singular_translation, :not_found}
    end
  end
end
