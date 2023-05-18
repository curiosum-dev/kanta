defmodule Kanta.Translations.Domains do
  alias Kanta.Repo

  alias Kanta.Translations.Domain
  alias Kanta.Translations.Domains.Finders.{ListDomains, GetDomain}

  def list_domains(params \\ []) do
    ListDomains.find(params)
  end

  def get_domain(params) do
    GetDomain.find(params)
  end

  def create_domain(attrs) do
    %Domain{}
    |> Domain.changeset(attrs)
    |> Repo.get_repo().insert()
  end
end
