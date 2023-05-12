defmodule KantaWeb.Translations.DomainsTable do
  use KantaWeb, :live_component

  def update(socket, assigns) do
    {:ok, assign(assigns, socket)}
  end

  def handle_event("edit_domain", %{"id" => id}, socket) do
    {:noreply,
     push_navigate(socket,
       to: path(socket, ~p"/kanta/domains/#{id}")
     )}
  end
end
