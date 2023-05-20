defmodule KantaWeb.Translations.Components.FiltersBar do
  @moduledoc """
  Messages filters bar component
  """

  use KantaWeb, :live_component

  alias Kanta.Translations

  alias KantaWeb.Components.Shared.{Select, SearchInput, Toggle}

  def update(assigns, socket) do
    %{entries: contexts, metadata: _contexts_metadata} = Translations.list_contexts()
    %{entries: domains, metadata: _domains_metadata} = Translations.list_domains()

    socket =
      socket
      |> assign(:contexts, contexts)
      |> assign(:domains, domains)
      |> assign(:filters, %{
        domain: nil,
        context: nil
      })

    {:ok, assign(socket, assigns)}
  end
end
