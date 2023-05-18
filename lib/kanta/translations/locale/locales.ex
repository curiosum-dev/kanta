defmodule Kanta.Translations.Locales do
  alias Kanta.Translations.Locale.Finders.{GetLocale, ListLocales}

  def list_locales(params \\ []) do
    ListLocales.find(params)
  end

  def get_locale(params \\ []) do
    GetLocale.find(params)
  end
end
