defmodule KantaWeb.Translations.MessagesTable do
  use KantaWeb, :live_component

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
                          Singular
                        </th>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                          Plural
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
                          <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                            <%= translated_singular_text(message) %>
                          </td>
                          <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                            <%= translated_plural_text(message) %>
                          </td>
                          <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                            <a phx-click="navigate" phx-value-to={Routes.translation_path(@socket, :show, @locale.id, message.id)} class="text-indigo-600 hover:text-indigo-900">Edit</a>
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

  def translated_singular_text(message) do
    if message.singular_translation do
      message.singular_translation.translated_text || "Not translated."
    else
      "---"
    end
  end

  def translated_plural_text(message) do
    if length(message.plural_translations) > 0 do
      Enum.map(message.plural_translations, fn translation ->
        "#{translation.nplural_index}: #{translation.translated_text || "Not translated."}\n"
      end)
    else
      "---"
    end
  end
end
