defmodule KantaWeb.Translations.MessagesTable do
  use KantaWeb, :live_component

  alias Kanta.Translations.Message

  def update(socket, assigns) do
    {:ok, assign(assigns, socket)}
  end

  def handle_event("edit_message", %{"id" => id}, socket) do
    {:noreply,
     push_navigate(socket,
       to: path(socket, ~p"/kanta/locales/#{socket.assigns.locale.id}/translations/#{id}")
     )}
  end

  def message_classnames(%Message{message_type: :singular} = message, locale) do
    translation = Enum.find(message.singular_translations, &(&1.locale_id == locale.id))

    if not is_nil(translation) and
         not is_nil(translation.translated_text) and
         String.length(translation.translated_text) > 0 do
      "whitespace-nowrap text-sm font-medium text-primary"
    else
      "whitespace-nowrap text-xs text-red-600"
    end
  end

  def message_classnames(%Message{message_type: :plural} = message, locale) do
    translations = Enum.filter(message.plural_translations, &(&1.locale_id == locale.id))

    if length(translations) > 0 and
         Enum.any?(
           translations,
           &(not is_nil(&1.translated_text) and String.length(&1.translated_text) > 0)
         ) do
      "text-sm font-medium text-primary"
    else
      "text-xs text-red-600"
    end
  end

  def translated_text(assigns, %Message{message_type: :singular} = message),
    do: translated_singular_text(assigns, message)

  def translated_text(assigns, %Message{message_type: :plural} = message),
    do: translated_plural_text(assigns, message)

  def translated_singular_text(assigns, message) do
    translation = Enum.find(message.singular_translations, &(&1.locale_id == assigns.locale.id))

    if translation do
      String.slice(translation.translated_text || "Not translated.", 0..30)
    else
      "---"
    end
  end

  def translated_plural_text(assigns, message) do
    translations = Enum.filter(message.plural_translations, &(&1.locale_id == assigns.locale.id))
    assigns = assign(assigns, :translations, translations)

    if length(translations) > 0 do
      ~H"""
        <div>
          <%= for plural_translation <- @translations do %>
            <div>
              Plural form <%= plural_translation.nplural_index %>: <%= String.slice(plural_translation.translated_text || "Not translated.", 0..30) %>
            </div>
          <% end %>
        </div>
      """
    else
      "---"
    end
  end
end
