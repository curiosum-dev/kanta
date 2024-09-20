defmodule KantaWeb.Translations.ContextsTable do
  @moduledoc """
  Gettext contexts table component
  """

  use KantaWeb, :live_component

  def update(socket, assigns) do
    {:ok, assign(assigns, socket)}
  end

  def handle_event("edit_context", %{"id" => id}, socket) do
    {:noreply, push_navigate(socket, to: dashboard_path(socket, "/contexts/#{id}"))}
  end
end
