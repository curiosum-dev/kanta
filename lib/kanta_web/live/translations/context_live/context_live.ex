defmodule KantaWeb.Translations.ContextLive do
  use KantaWeb, :live_view

  alias Kanta.Translations
  alias Kanta.Translations.Context

  def mount(%{"id" => id}, _session, socket) do
    context =
      case Translations.get_context(filter: [id: id]) do
        {:ok, %Context{} = context} -> context
        {:error, _, _reason} -> nil
      end

    socket = socket |> assign(:context, context)

    {:ok, socket}
  end
end
