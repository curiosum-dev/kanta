defmodule KantaWeb.Dashboard.DashboardLive do
  use KantaWeb, :live_view

  alias Kanta.Translations

  def mount(_params, _session, socket) do
    messages_count = Translations.get_messages_count()
    locales = Translations.list_locales()

    socket =
      socket
      |> assign(:messages_count, messages_count)
      |> assign(:languages, locales)

    {:ok, socket}
  end

  def translation_progress(language) do
    Translations.get_locale_translation_progress(language.id)
  end
end
