defmodule KantaWeb.Translations.DomainsTabBar do
  use KantaWeb, :live_component

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end
