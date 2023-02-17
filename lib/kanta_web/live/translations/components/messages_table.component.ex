defmodule KantaWeb.Translations.MessagesTable do
  use KantaWeb, :live_component

  alias Kanta.Translations.Message

  def render(assigns) do
    ~H"""
    <div class="bg-gray-100 py-6">
      <div class="w-full">
          <div class="flex flex-col">
            <div class="-my-2 overflow-x-auto">
              <div class="py-2 align-middle inline-block min-w-full">
                <div class="shadow overflow-hidden border-b border-gray-200 sm:rounded-lg">
                  <table class="min-w-full w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                      <tr>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                          Message ID
                        </th>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                          Type
                        </th>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                          Translation
                        </th>
                        <th scope="col" class="relative px-6 py-3">
                          <span class="sr-only">Edit</span>
                        </th>
                      </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                      <%= for message <- @messages do %>
                        <tr>
                          <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                            <%= message.msgid %>
                          </td>
                          <td>
                            <span class="inline-flex items-center px-2.5 py-0.5 rounded-full uppercase text-xs font-medium bg-primary-main text-white">
                              <%= message.message_type %>
                            </span>
                          </td>
                          <td class={message_classnames(message)}>
                            <%= translated_text(assigns, message) %>
                          </td>
                          <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                            <a phx-click="navigate" phx-value-to={Routes.translation_path(@socket, :show, @locale.id, message.id)} class="cursor-pointer text-indigo-600 hover:text-indigo-900">Edit</a>
                          </td>
                        </tr>
                      <% end %>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          </div>
      </div>
    </div>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end

  def message_classnames(%Message{message_type: :singular} = message) do
    if not is_nil(message.singular_translation) and
         not is_nil(message.singular_translation.translated_text) and
         String.length(message.singular_translation.translated_text) > 0 do
      "px-6 py-4 whitespace-nowrap text-sm font-medium text-primary-main"
    else
      "px-6 py-4 whitespace-nowrap text-xs text-red-600"
    end
  end

  def message_classnames(%Message{message_type: :plural} = message) do
    if length(message.plural_translations) > 0 and
         Enum.any?(
           message.plural_translations,
           &(not is_nil(&1.translated_text) and String.length(&1.translated_text) > 0)
         ) do
      "px-6 py-4 text-sm font-medium text-primary-main"
    else
      "px-6 py-4 text-xs text-red-600"
    end
  end

  def translated_text(assigns, %Message{message_type: :singular} = message),
    do: translated_singular_text(assigns, message)

  def translated_text(assigns, %Message{message_type: :plural} = message),
    do: translated_plural_text(assigns, message)

  def translated_singular_text(_assigns, message) do
    if message.singular_translation do
      message.singular_translation.translated_text || "Not translated."
    else
      "---"
    end
  end

  def translated_plural_text(assigns, message) do
    assigns = assign(assigns, :message, message)

    if length(message.plural_translations) > 0 do
      ~H"""
        <div>
          <%= for plural_translation <- @message.plural_translations do %>
            <div>
              Plural form <%= plural_translation.nplural_index %>: <%= plural_translation.translated_text || "Not translated." %>
            </div>
          <% end %>
        </div>
      """
    else
      "---"
    end
  end
end
