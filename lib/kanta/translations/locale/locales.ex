defmodule Kanta.Translations.Locales do
  use Nebulex.Caching

  alias Kanta.Cache
  alias Kanta.Repo

  alias Kanta.Translations.Locale
  alias Kanta.Translations.LocaleQueries

  @ttl :timer.hours(12)

  @decorate cacheable(cache: Cache, key: Locale, opts: [ttl: @ttl])
  def list_locales do
    LocaleQueries.all()
    |> Repo.get_repo().all()
  end

  @decorate cacheable(cache: Cache, key: {Locale, name}, opts: [ttl: @ttl])
  def get_or_create_locale_by_name(name) do
    case get_locale_by_name(name) do
      %Locale{} = locale -> locale
      nil -> create_locale!(name)
    end
  end

  @decorate cacheable(cache: Cache, key: {Locale, name}, opts: [ttl: @ttl])
  defp get_locale_by_name(name) do
    LocaleQueries.filter(name: name)
    |> Repo.get_repo().one()
  end

  defp create_locale!(name) do
    Locale.changeset(%Locale{}, %{name: name})
    |> Kanta.Repo.get_repo().insert!()
  end
end
