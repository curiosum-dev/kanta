defmodule KantaWeb.Translations.DomainLive do
  use KantaWeb, :live_view

  alias Kanta.Translations
  alias Kanta.Translations.Domain

  def mount(%{"id" => id}, _session, socket) do
    domain =
      case Translations.get_domain(filter: [id: id]) do
        {:ok, %Domain{} = domain} -> domain
        {:error, _} -> nil
      end

    socket = socket |> assign(:domain, domain)

    {:ok, socket}
  end
end
