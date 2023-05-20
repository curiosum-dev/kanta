defmodule Kanta.Translations.Messages.Finders.GetMessage do
  @moduledoc """
  Query module aka Finder responsible for finding gettext message
  """

  use Kanta.Query,
    module: Kanta.Translations.Message,
    binding: :message

  alias Kanta.Cache
  alias Kanta.Translations.Message

  def find(params \\ []) do
    cache_key = Cache.generate_cache_key("message", params)

    with {:error, _, :not_cached} <- find_in_cache(cache_key),
         {:ok, %Message{} = message} <- find_in_database(params) do
      Cache.put(cache_key, message)

      {:ok, message}
    else
      {:ok, %Message{} = message} -> {:ok, message}
      {:error, _, :not_found} -> {:error, :message, :not_found}
    end
  end

  defp find_in_cache(cache_key) do
    case Cache.get(cache_key) do
      nil ->
        {:error, :message, :not_cached}

      cached_message ->
        {:ok, cached_message}
    end
  end

  defp find_in_database(params) do
    base()
    |> filter_query(params[:filter])
    |> search_query(params[:search])
    |> preload_resources(params[:preloads] || [])
    |> one()
    |> case do
      %Message{} = message -> {:ok, message}
      _ -> {:error, :message, :not_found}
    end
  end
end
