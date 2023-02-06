defmodule Kanta.Translations.Locales do
  alias Kanta.Translations.LocaleQueries
  alias Kanta.Repo

  def list_locales do
    LocaleQueries.all()
    |> Repo.get_repo().all()
  end

  def get_or_create_locale_by_name(name) do
    with nil <- get_locale_by_name(name),
         locale = create_locale!(name) do
      locale
    end
  end

  defp get_locale_by_name(name) do
    LocaleQueries.filter(name: name)
    |> Repo.get_repo().one()
  end

  defp create_locale!(name) do
    %Kanta.Translations.Locale{}
    |> Kanta.Translations.Locale.changeset(%{name: name})
    |> Kanta.Repo.get_repo().insert!()
  end
end
