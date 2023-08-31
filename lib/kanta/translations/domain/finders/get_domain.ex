defmodule Kanta.Translations.Domains.Finders.GetDomain do
  @moduledoc """
  Query module aka Finder responsible for finding gettext domain
  """

  use Kanta.Query,
    module: Kanta.Translations.Domain,
    binding: :domain

  alias Kanta.Cache
  alias Kanta.Translations.Domain

  def find(params \\ []) do
    cache_key = Cache.generate_cache_key("domain", params)

    with {:error, _, :not_cached} <- find_in_cache(cache_key),
         {:ok, %Domain{} = domain} <- find_in_database(params) do
      Cache.put(cache_key, domain)

      {:ok, domain}
    else
      {:ok, %Domain{} = domain} -> {:ok, domain}
      {:error, _, :not_found} -> {:error, :domain, :not_found}
    end
  end

  defp find_in_cache(cache_key) do
    case Cache.get(cache_key) do
      nil ->
        {:error, :domain, :not_cached}

      cached_domain ->
        {:ok, cached_domain}
    end
  end

  defp find_in_database(params) do
    base()
    |> filter_query(params[:filter])
    |> preload_resources(params[:preloads] || [])
    |> one()
    |> case do
      %Domain{} = domain -> {:ok, domain}
      _ -> {:error, :domain, :not_found}
    end
  end
end
