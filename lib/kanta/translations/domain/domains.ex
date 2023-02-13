defmodule Kanta.Translations.Domains do
  use Nebulex.Caching

  alias Kanta.Cache
  alias Kanta.Repo

  alias Kanta.Translations.Domain
  alias Kanta.Translations.DomainQueries

  @ttl :timer.hours(12)

  @decorate cacheable(cache: Cache, key: {Domain, name}, opts: [ttl: @ttl])
  def get_or_create_domain_by_name(name) do
    case get_domain_by_name(name) do
      %Domain{} = domain -> domain
      nil -> create_domain!(name)
    end
  end

  @decorate cacheable(cache: Cache, key: {Domain, name}, opts: [ttl: @ttl])
  defp get_domain_by_name(name) do
    DomainQueries.filter(name: name)
    |> Repo.get_repo().one()
  end

  defp create_domain!(name) do
    %Kanta.Translations.Domain{}
    |> Kanta.Translations.Domain.changeset(%{name: name})
    |> Kanta.Repo.get_repo().insert!()
  end
end
