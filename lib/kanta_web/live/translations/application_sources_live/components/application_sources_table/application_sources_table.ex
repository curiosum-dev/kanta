defmodule KantaWeb.Translations.ApplicationSourcesTable do
  @moduledoc """
  Application sources table component
  """

  use KantaWeb, :live_component

  def update(socket, assigns) do
    {:ok, assign(assigns, socket)}
  end

  def handle_event("edit_application_source", %{"id" => id}, socket) do
    {:noreply, push_navigate(socket, to: dashboard_path(socket, "/application_sources/#{id}"))}
  end
end
