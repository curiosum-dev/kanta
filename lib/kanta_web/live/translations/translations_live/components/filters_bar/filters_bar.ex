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

    {col_span, grid_cols} =
      if assigns.application_sources_empty?,
        do: {"col-span-5", "grid-cols-5"},
        else: {"col-span-6", "grid-cols-6"}

    socket =
      socket
      |> assign(:contexts, contexts)
      |> assign(:domains, domains)
      |> assign(:application_sources, application_sources)
      |> assign(:col_span, col_span)
      |> assign(:grid_cols, grid_cols)
      |> assign(:filters, %{
        domain: nil,
        context: nil,
        application_source: nil
      })

    {:ok, assign(socket, assigns)}
  end
end
