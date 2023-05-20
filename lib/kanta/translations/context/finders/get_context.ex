defmodule Kanta.Translations.Contexts.Finders.GetContext do
  @moduledoc """
  Query module aka Finder responsible for finding gettext context
  """

  use Kanta.Query,
    module: Kanta.Translations.Context,
    binding: :context

  alias Kanta.Cache
  alias Kanta.Translations.Context

  def find(params \\ []) do
    cache_key = Cache.generate_cache_key("context", params)

    with {:error, _, :not_cached} <- find_in_cache(cache_key),
         {:ok, %Context{} = context} <- find_in_database(params) do
      Cache.put(cache_key, context)

      {:ok, context}
    else
      {:ok, %Context{} = context} -> {:ok, context}
      {:error, _, :not_found} -> {:error, :context, :not_found}
    end
  end

  defp find_in_cache(cache_key) do
    case Cache.get(cache_key) do
      nil ->
        {:error, :context, :not_cached}

      cached_context ->
        {:ok, cached_context}
    end
  end

  defp find_in_database(params) do
    base()
    |> filter_query(params[:filter])
    |> search_query(params[:search])
    |> preload_resources(params[:preloads] || [])
    |> one()
    |> case do
      %Context{} = context -> {:ok, context}
      _ -> {:error, :context, :not_found}
    end
  end
end
