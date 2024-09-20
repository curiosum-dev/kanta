defmodule KantaWeb.Translations.DomainLive do
  use KantaWeb, :live_view

  import Kanta.Utils.ParamParsers, only: [parse_id_filter: 1]

  alias Kanta.Translations
  alias Kanta.Translations.Domain

  def mount(%{"id" => id}, _session, socket) do
    socket =
      case get_domain(id) do
        {:ok, %Domain{} = domain} -> assign(socket, :domain, domain)
        {:error, _, _reason} -> redirect(socket, to: "/kanta/domains")
      end

    {:ok, socket}
  end

  defp get_domain(id) do
    case parse_id_filter(id) do
      {:ok, id} -> Translations.get_domain(filter: [id: id])
      _ -> {:error, :id, :invalid}
    end
  end
end
