defmodule KantaWeb.Translations.ContextsLive do
  use KantaWeb, :live_view

  alias Kanta.Translations
  alias KantaWeb.Translations.ContextsTable

  alias KantaWeb.Components.Shared.Pagination

  def mount(_params, _session, socket) do
    %{entries: contexts, metadata: contexts_metadata} = Translations.list_contexts()

    socket =
      socket
      |> assign(:contexts, contexts)
      |> assign(:contexts_metadata, contexts_metadata)

    {:ok, socket}
  end

  def handle_event("navigate", %{"to" => to}, socket) do
    {:noreply, push_redirect(socket, to: socket.router.__kanta_dashboard_prefix__() <> to)}
  end

  def handle_event("page_changed", %{"index" => page_number}, socket) do
    %{entries: contexts, metadata: contexts_metadata} =
      Translations.list_contexts(page: String.to_integer(page_number))

    socket =
      socket
      |> assign(:contexts, contexts)
      |> assign(:contexts_metadata, contexts_metadata)

    {:noreply, socket}
  end
end
