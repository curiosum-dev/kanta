defmodule Kanta.Services.PopulateCacheWithStoredDataService do
  alias Kanta.Translations
  alias Kanta.Cache.Agent

  def run do
    Translations.list_singular_translations()
    |> Enum.map(&Agent.cache_translation/1)
  end
end
