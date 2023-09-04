defmodule KantaWeb.Components.Shared.Toggle do
  @moduledoc """
  Toggle/Checkbox component
  """

  use KantaWeb, :live_component

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def handle_event("update", %{"id" => _id, "state" => _is_on}, socket) do
    {:noreply, socket}
  end
end
