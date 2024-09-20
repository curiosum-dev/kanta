defmodule KantaWeb.Translations.ContextLive do
  use KantaWeb, :live_view

  import Kanta.Utils.ParamParsers, only: [parse_id_filter: 1]

  alias Kanta.Translations
  alias Kanta.Translations.Context

  def mount(%{"id" => id}, _session, socket) do
    socket =
      case get_context(id) do
        {:ok, %Context{} = context} -> assign(socket, :context, context)
        {:error, _, _reason} -> redirect(socket, to: "/kanta/contexts")
      end

    {:ok, socket}
  end

  defp get_context(id) do
    case parse_id_filter(id) do
      {:ok, id} -> Translations.get_context(filter: [id: id])
      _ -> {:error, :id, :invalid}
    end
  end
end
