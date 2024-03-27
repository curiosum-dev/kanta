defmodule KantaWeb.Translations.ApplicationSourceLive do
  use KantaWeb, :live_view

  alias Kanta.Translations
  alias Kanta.Translations.ApplicationSource

  def mount(%{"id" => id}, _session, socket) do
    application_source =
      case Translations.get_application_source(filter: [id: id]) do
        {:ok, %ApplicationSource{} = application_source} -> application_source
        {:error, _, _reason} -> nil
      end

    socket = socket |> assign(:application_source, application_source)

    {:ok, socket}
  end
end
