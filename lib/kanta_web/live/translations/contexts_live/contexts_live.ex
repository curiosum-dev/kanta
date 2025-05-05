defmodule KantaWeb.Translations.ContextsLive do
  alias Kanta.DataAccess.PaginationMeta
  alias KantaWeb.Translations.ContextsTable
  use KantaWeb, :live_view

  @page_size 50

  alias KantaWeb.Components.Shared.Pagination

  def mount(_params, session, socket) do
    data_access = session["data_access"]
    pagination_params = pagination_params(1)

    socket =
      socket
      |> assign_data_access(data_access)
      |> assign_contexts(%{pagination: pagination_params})

    {:ok, socket, temporary_assigns: [contexts: []]}
  end

  def handle_event("navigate", %{"to" => to}, socket) do
    {:noreply, push_navigate(socket, to: dashboard_path(socket) <> to)}
  end

  def handle_event("page_changed", %{"index" => page_number}, socket) do
    page_number = String.to_integer(page_number)

    socket =
      assign_contexts(socket, %{pagination: pagination_params(page_number)})

    {:noreply, socket}
  end

  defp assign_contexts(socket, list_params) do
    data_access = get_data_access(socket)

    {:ok, {contexts, %PaginationMeta{} = pm}} = data_access.list_resources(:context, list_params)

    socket
    |> assign(contexts: contexts, current_page: pm.page, total_pages: pm.total_pages)
  end

  defp assign_data_access(socket, data_access), do: assign(socket, data_access: data_access)
  defp get_data_access(socket), do: socket.assigns.data_access

  defp pagination_params(page_number), do: %{type: :page, page: page_number, size: @page_size}
end
