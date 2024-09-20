defmodule Kanta.Translations.Locales do
  @moduledoc """
  Locales Kanta subcontext
  """

  alias Kanta.Repo

  alias Kanta.Translations.Locale
  alias Kanta.Translations.Locale.Finders.{GetLocale, ListLocales}

  def list_locales(params \\ []) do
    ListLocales.find(params)
  end

  def get_locale(params \\ []) do
    GetLocale.find(params)
  end

  def update_locale(locale, attrs \\ %{}, opts \\ []) do
    Locale.changeset(locale, attrs)
    |> Repo.get_repo().update(opts)
  end
end
