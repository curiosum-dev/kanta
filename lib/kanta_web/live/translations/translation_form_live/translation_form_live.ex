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
    locale = Translations.get_locale(locale_id)
    message = Translations.get_message(message_id)

    translations = get_translations(message, locale_id)

    socket =
      socket
      |> assign(:locale, locale)
      |> assign(:message, message)
      |> assign(:translations, translations)

    {:ok, socket}
  end

  defp get_translations(%Message{message_type: :singular} = message, locale_id) do
    Translations.get_singular_translation_by(%{
      "filter" => %{
        "message_id" => message.id,
        "locale_id" => locale_id
      }
    })
  end

  defp get_translations(%Message{message_type: :plural} = message, locale_id) do
    Translations.list_plural_translations(%{
      "filter" => %{
        "message_id" => message.id,
        "locale_id" => locale_id
      }
    })
  end
end
