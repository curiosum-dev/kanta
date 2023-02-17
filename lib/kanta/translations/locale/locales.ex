defmodule Kanta.Translations.Locales do
  use Nebulex.Caching

  alias Kanta.Cache
  alias Kanta.Repo

  alias Kanta.Translations.Locale
  alias Kanta.Translations.LocaleQueries

  @ttl :timer.hours(12)

  @decorate cacheable(cache: Cache, key: Locale, opts: [ttl: @ttl])
  def list_locales do
    LocaleQueries.base()
    |> Repo.get_repo().all()
  end

  @decorate cacheable(cache: Cache, key: {Locale, id}, opts: [ttl: @ttl])
  def get_locale(id) do
    Repo.get_repo().get(Locale, id)
  end

  @decorate cacheable(cache: Cache, key: {Locale, params}, opts: [ttl: @ttl])
  def get_locale_by(params) do
    LocaleQueries.base()
    |> LocaleQueries.filter_query(params["filter"])
    |> Repo.get_repo().one()
  end

  @decorate cacheable(cache: Cache, key: {Locale, params}, opts: [ttl: @ttl])
  def get_or_create_locale_by(params) do
    case get_locale_by(params) do
      %Locale{} = locale -> locale
      nil -> create_locale!(params["filter"])
    end
  end

  defp create_locale!(attrs) do
    %Locale{}
    |> Locale.changeset(attrs)
    |> Kanta.Repo.get_repo().insert!()
  end
end
