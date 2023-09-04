defmodule KantaWeb.Components.Shared.Tabs do
  @moduledoc """
  Tabs component
  """

  use KantaWeb, :live_component

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def handle_event("tab_clicked", %{"index" => index}, socket) do
    {:noreply, push_patch(socket, to: "#{socket.assigns.current_url}?tab=#{index}")}
  end
end
