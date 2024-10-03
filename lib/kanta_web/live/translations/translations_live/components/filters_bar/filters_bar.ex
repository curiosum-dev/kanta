defmodule KantaWeb.Translations.Components.FiltersBar do
  @moduledoc """
  Messages filters bar component
  """

  use KantaWeb, :live_component

  alias Kanta.Translations

  alias KantaWeb.Components.Shared.{SearchInput, Select, Toggle}

  def update(assigns, socket) do
    %{entries: contexts, metadata: _contexts_metadata} = Translations.list_contexts()
    %{entries: domains, metadata: _domains_metadata} = Translations.list_domains()

    %{entries: application_sources, metadata: _application_sources_metadata} =
      Translations.list_application_sources()

    socket =
      socket
      |> assign(:contexts, contexts)
      |> assign(:domains, domains)
      |> assign(:application_sources, application_sources)
      |> assign(:filters, %{
        domain: nil,
        context: nil,
        application_source: nil
      })

    {:ok, assign(socket, assigns)}
  end
end
