defmodule Kanta.Translations.Locales do
  @moduledoc """
  Locales Kanta subcontext
  """

  alias Kanta.Translations.Locale.Finders.{GetLocale, ListLocales}

  def list_locales(params \\ []) do
    ListLocales.find(params)
  end

  def get_locale(params \\ []) do
    GetLocale.find(params)
  end
end
