defmodule KantaWeb.Translations.SingularTranslationForm do
  @moduledoc """
  Singular translation form component
  """

  use KantaWeb, :live_component

  alias Kanta.Translations
  alias Kanta.Plugins.DeepL.Adapter

  def update(assigns, socket) do
    socket =
      socket
      |> assign(:form, %{
        "original_text" => assigns[:translation].original_text,
        "translated_text" => assigns[:translation].translated_text
      })

    {:ok, assign(socket, assigns)}
  end

  def handle_event("overwrite_po", _, socket) do
    %{form: form, translation: translation, locale: locale, message: message} = socket.assigns

    Kanta.Plugins.POWriter.OverwritePoMessage.singular(form["translated_text"], locale, message)

    Translations.update_singular_translation(translation.id, %{
      "original_text" => form["translated_text"]
    })

    {:noreply, socket}
  end

  def handle_event("translate_via_deep_l", _, socket) do
    locale = socket.assigns.locale
    message = socket.assigns.message

    case Adapter.request_translation("EN", String.upcase(locale.iso639_code), message.msgid) do
      {:ok, translations} ->
        %{"text" => translated_text} = List.first(translations)

        {:noreply, update(socket, :form, &Map.merge(&1, %{"translated_text" => translated_text}))}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("validate", %{"translated_text" => translation}, socket) do
    {:noreply, update(socket, :form, &Map.merge(&1, %{"translated_text" => translation}))}
  end

  def handle_event("submit", %{"translated_text" => translated}, socket) do
    locale = socket.assigns.locale
    translation = socket.assigns.translation

    Translations.update_singular_translation(translation, %{"translated_text" => translated})

    {:noreply,
     push_redirect(socket, to: unverified_url(socket, "/kanta/locales/#{locale.id}/translations"))}
  end
end
