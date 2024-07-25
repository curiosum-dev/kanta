defmodule KantaWeb.Translations.DomainsLive do
  use KantaWeb, :live_view

  alias Kanta.Translations
  alias KantaWeb.Translations.DomainsTable

  alias KantaWeb.Components.Shared.Pagination

  def mount(_params, _session, socket) do
    %{entries: domains, metadata: domains_metadata} = Translations.list_domains()

    socket =
      socket
      |> assign(:domains, domains)
      |> assign(:domains_metadata, domains_metadata)

    {:ok, socket}
  end

  def handle_event("navigate", %{"to" => to}, socket) do
    {:noreply, push_navigate(socket, to: "/kanta" <> to)}
  end

  def handle_event("page_changed", %{"index" => page_number}, socket) do
    %{entries: domains, metadata: domains_metadata} =
      Translations.list_domains(page: String.to_integer(page_number))

    socket =
      socket
      |> assign(:domains, domains)
      |> assign(:domains_metadata, domains_metadata)

    {:noreply, socket}
  end
end
