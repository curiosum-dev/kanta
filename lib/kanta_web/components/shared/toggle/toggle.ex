defmodule KantaWeb.Components.Shared.Toggle do
  use KantaWeb, :live_component

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def handle_event("update", %{"id" => id, "state" => is_on}, socket) do
    {:noreply, socket}
  end
end
