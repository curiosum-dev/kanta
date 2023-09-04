defmodule KantaWeb.Translations.SingularTranslationForm do
  @moduledoc """
  Singular translation form component
  """

  use KantaWeb, :live_component

  alias Kanta.Translations

  def update(assigns, socket) do
    socket =
      socket
      |> assign(:form, %{
        "original_text" => assigns[:translation].original_text,
        "translated_text" => assigns[:translation].translated_text
      })

    {:ok, assign(socket, assigns)}
  end

  def handle_event("validate", %{"translated_text" => translation}, socket) do
    {:noreply, update(socket, :form, &Map.merge(&1, %{"translated_text" => translation}))}
  end

  def handle_event("submit", %{"translated_text" => translated}, socket) do
    locale = socket.assigns.locale
    translation = socket.assigns.translation

    Translations.update_singular_translation(translation, %{"translated_text" => translated})

    {:noreply,
     push_redirect(socket,
       to:
         unverified_path(
           socket,
           Kanta.Router,
           "/kanta/locales/#{locale.id}/translations"
         )
     )}
  end
end
