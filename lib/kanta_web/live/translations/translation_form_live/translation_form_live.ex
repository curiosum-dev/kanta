defmodule KantaWeb.Translations.TranslationFormLive do
  use KantaWeb, :live_view

  alias Kanta.Translations
  alias Kanta.Translations.Message

  alias KantaWeb.Translations.{PluralTranslationForm, SingularTranslationForm}

  def render(%{message: %Message{message_type: :singular}} = assigns) do
    ~H"""
      <.live_component
        module={SingularTranslationForm}
        id="singular-translation-form"
        translation={@translations}
        message={@message}
        locale={@locale}
      />
    """
  end

  def render(%{message: %Message{message_type: :plural}} = assigns) do
    ~H"""
      <.live_component
        module={PluralTranslationForm}
        id="plural-translation-form"
        translations={@translations}
        message={@message}
        locale={@locale}
      />
    """
  end

  def mount(%{"message_id" => message_id, "locale_id" => locale_id}, _session, socket) do
    socket =
      with {:ok, locale} <- Translations.get_locale(filter: [id: locale_id]),
           {:ok, message} <- Translations.get_message(filter: [id: message_id]),
           {:ok, translations} <- get_translations(message, locale_id) do
        socket
        |> assign(:locale, locale)
        |> assign(:message, message)
        |> assign(:translations, translations)
      end

    {:ok, socket}
  end

  defp get_translations(%Message{message_type: :singular} = message, locale_id) do
    Translations.get_singular_translation(
      filter: [
        locale_id: locale_id,
        message_id: message.id
      ]
    )
  end

  defp get_translations(%Message{message_type: :plural} = message, locale_id) do
    Translations.list_plural_translations(
      filter: [
        locale_id: locale_id,
        message_id: message.id
      ]
    )
  end
end
