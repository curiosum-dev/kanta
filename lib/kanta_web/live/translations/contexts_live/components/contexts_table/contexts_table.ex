defmodule KantaWeb.Translations.ContextsTable do
  @moduledoc """
  Gettext contexts table component
  """

  use KantaWeb, :live_component

  def update(socket, assigns) do
    {:ok, assign(assigns, socket)}
  end

  def handle_event("edit_context", %{"id" => id}, socket) do
    {:noreply,
     push_navigate(socket,
       to:
         unverified_path(
           socket,
           Kanta.Router,
           "#{socket.router.__kanta_dashboard_prefix__()}/contexts/#{id}"
         )
     )}
  end
end
