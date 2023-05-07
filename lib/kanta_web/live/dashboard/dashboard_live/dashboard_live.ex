defmodule KantaWeb.Dashboard.DashboardLive do
  use KantaWeb, :live_view

  alias Kanta.Translations
  alias Kanta.External.DeepL.Adapter

  def mount(_params, _session, socket) do
    messages_count = Translations.get_messages_count()
    locales = Translations.list_locales()

    {:ok, %{"character_count" => character_count, "character_limit" => character_limit}} =
      Adapter.usage()

    socket =
      socket
      |> assign(:messages_count, messages_count)
      |> assign(:languages, locales)
      |> assign(:deep_l_usage, Float.ceil(character_count / character_limit, 2))

    {:ok, socket}
  end

  def translation_progress(language) do
    Translations.get_locale_translation_progress(language.id)
  end
end
