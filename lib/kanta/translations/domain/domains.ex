defmodule Kanta.Translations.Domains do
  alias Kanta.Cache
  alias Kanta.Repo

  alias Kanta.Translations.Domain

  @cache_prefix "domain_"
  @ttl :timer.seconds(3600)

  def list_domains do
    Repo.get_repo().all(Domain)
  end

  def get_domain(id) do
    Repo.get_repo().get(Domain, id)
  end

  def get_domain_by(params) do
    cache_key = @cache_prefix <> URI.encode_query(params)

    case Cache.get(cache_key) do
      nil ->
        case Repo.get_repo().get_by(Domain, params) do
          %Domain{} = domain ->
            Cache.put(cache_key, domain, ttl: @ttl)

            domain

          _ ->
            :not_found
        end

      cached_domain ->
        cached_domain
    end
  end

  def get_or_create_domain_by(params) do
    case get_domain_by(params) do
      %Domain{} = domain -> domain
      :not_found -> create_domain!(%{name: params[:name]})
    end
  end

  defp create_domain!(attrs) do
    %Kanta.Translations.Domain{}
    |> Kanta.Translations.Domain.changeset(attrs)
    |> Kanta.Repo.get_repo().insert!()
  end
end
