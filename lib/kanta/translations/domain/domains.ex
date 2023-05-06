defmodule Kanta.Translations.Domains do
  alias Kanta.Cache
  alias Kanta.Repo

  alias Kanta.Translations.Domain
  alias Kanta.Translations.DomainQueries

  def list_domains do
    DomainQueries.base()
    |> Repo.get_repo().all()
  end

  def get_domain(id) do
    Repo.get_repo().get(Domain, id)
  end

  def get_domain_by(params) do
    DomainQueries.base()
    |> DomainQueries.filter_query(params["filter"])
    |> Repo.get_repo().one()
  end

  def get_or_create_domain_by(params) do
    case get_domain_by(params) do
      %Domain{} = domain -> domain
      nil -> create_domain!(params["filter"])
    end
  end

  defp create_domain!(attrs) do
    %Kanta.Translations.Domain{}
    |> Kanta.Translations.Domain.changeset(attrs)
    |> Kanta.Repo.get_repo().insert!()
  end
end
