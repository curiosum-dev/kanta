defmodule KantaWeb.Translations.DomainsLive do
  alias Kanta.DataAccess.PaginationMeta
  use KantaWeb, :live_view

  alias Kanta.Translations
  alias KantaWeb.Translations.DomainsTable

  alias KantaWeb.Components.Shared.Pagination

  def mount(_params, session, socket) do
    # %{entries: domains, metadata: domains_metadata} = Translations.list_domains()
    data_access = session["data_access"]
    {:ok, {domains, %PaginationMeta{} = pm}} = data_access.list_resources(:domain, %{}) |> dbg()

    socket =
      socket
      |> assign(
        domains: domains,
        current_page: pm.page,
        total_pages: pm.total_pages
      )

    {:ok, socket}
  end

  def handle_event("navigate", %{"to" => to}, socket) do
    {:noreply, push_navigate(socket, to: dashboard_path(socket) <> to)}
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
