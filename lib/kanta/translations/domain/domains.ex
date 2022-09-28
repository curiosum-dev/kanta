defmodule Kanta.Translations.Domains do
  alias Kanta.Translations.DomainQueries
  alias Kanta.Repo

  def get_or_create_domain_by_name(name) do
    with nil <- get_domain_by_name(name),
         domain = create_domain!(name) do
      domain
    end
  end

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
