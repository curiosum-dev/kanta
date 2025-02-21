defmodule KantaWeb.Translations.ApplicationSourcesLive do
  use KantaWeb, :live_view

  alias Kanta.Translations
  alias KantaWeb.Translations.ApplicationSourcesTable

  alias KantaWeb.Components.Shared.Pagination

  def mount(_params, _session, socket) do
    %{entries: application_sources, metadata: application_sources_metadata} =
      Translations.list_application_sources()

    socket =
      socket
      |> assign(:application_sources, application_sources)
      |> assign(:application_sources_metadata, application_sources_metadata)

    {:ok, socket}
  end

  def handle_event("navigate", %{"to" => to}, socket) do
    {:noreply, push_navigate(socket, to: "/kanta" <> to)}
  end

  def handle_event("page_changed", %{"index" => page_number}, socket) do
    %{entries: application_sources, metadata: application_sources_metadata} =
      Translations.list_application_sources(page: String.to_integer(page_number))

    socket =
      socket
      |> assign(:application_sources, application_sources)
      |> assign(:application_sources_metadata, application_sources_metadata)

    {:noreply, socket}
  end
end
