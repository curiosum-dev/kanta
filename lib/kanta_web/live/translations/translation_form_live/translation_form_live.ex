defmodule KantaWeb.Translations.TranslationFormLive do
  use KantaWeb, :live_view

  import Kanta.Utils.ParamParsers, only: [parse_id_filter: 1]

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
    assigns =
      if is_map_key(assigns, :tab) do
        assigns
      else
        assign(assigns, :tab, "1")
      end

    ~H"""
      <.live_component
        module={PluralTranslationForm}
        id="plural-translation-form"
        translations={@translations}
        message={@message}
        locale={@locale}
        current_tab={@tab}
        current_tab_index={String.to_integer(@tab) - 1}
      />
    """
  end

  def mount(%{"message_id" => message_id, "locale_id" => locale_id}, _session, socket) do
    socket =
      with {:ok, locale} <- get_locale(locale_id),
           {:ok, message} <- get_message(message_id),
           {:ok, translations} <- get_translations(message, locale) do
        socket
        |> assign(:locale, locale)
        |> assign(:message, message)
        |> assign(:translations, translations)
      else
        _ -> redirect(socket, to: "/kanta/locales/#{locale_id}/translations")
      end

    {:ok, socket}
  end

  def handle_params(%{"tab" => tab}, _uri, socket) do
    {:noreply,
     socket
     |> assign(:tab, tab)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  defp get_translations(%Message{message_type: :singular} = message, locale) do
    case Translations.get_singular_translation(
           filter: [
             locale_id: locale.id,
             message_id: message.id
           ]
         ) do
      {:ok, translations} ->
        {:ok, translations}

      {:error, _, _} ->
        Translations.create_singular_translation(%{
          original_text: nil,
          translated_text: nil,
          locale_id: locale.id,
          message_id: message.id
        })
    end
  end

  defp get_translations(%Message{message_type: :plural} = message, locale) do
    case Translations.list_plural_translations(
           filter: [
             locale_id: locale.id,
             message_id: message.id
           ]
         ) do
      %{entries: entries} when entries != [] ->
        {:ok, entries}

      _ ->
        with {:ok, %{nplurals: plurals_count}} <- Expo.PluralForms.parse(locale.plurals_header) do
          {
            :ok,
            Enum.map(0..plurals_count, fn index ->
              case(
                Translations.create_plural_translation(%{
                  nplural_index: index,
                  original_text: nil,
                  translated_text: nil,
                  locale_id: locale.id,
                  message_id: message.id
                })
              ) do
                {:ok, translation} -> translation
                _ -> nil
              end
            end)
            |> Enum.reject(&is_nil/1)
          }
        end
    end
  end

  defp get_locale(locale_id) do
    case parse_id_filter(locale_id) do
      {:ok, id} -> Translations.get_locale(filter: [id: id])
      _ -> {:error, :id, :invalid}
    end
  end

  defp get_message(message_id) do
    case parse_id_filter(message_id) do
      {:ok, id} -> Translations.get_message(filter: [id: id])
      _ -> {:error, :id, :invalid}
    end
  end
end
