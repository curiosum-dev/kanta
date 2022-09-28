defmodule KantaWeb.Admin.StorageController do
  use KantaWeb, :controller
  alias Kanta.{Storage, CacheAgent}

  def index(conn, _params) do
    stored_translations = Storage.get_all_stored_translations()
    cached_translations = CacheAgent.get_all_cached_translations()

    consistency = consistency?(stored_translations, cached_translations)

    render(conn, "index.html", consistency: consistency, translations: stored_translations)
  end

  defp consistency?(stored_translations, cached_translations) do
    stored_translations_set = MapSet.new(stored_translations)
    cached_translations_set = MapSet.new(cached_translations)

    stored_translations_set
    |> MapSet.equal?(cached_translations_set)
  end
end
