defmodule KantaWeb.Translations.DomainsTabBar do
  use KantaWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="bg-gray-100">
    <div class="w-full mx-auto">
      <div>
        <div class="sm:hidden">
          <label for="tabs" class="sr-only">Select a tab</label>
          <select id="tabs" name="tabs" class="block w-full focus:ring-indigo-500 focus:border-indigo-500 border-gray-300 rounded-md">
          <%= for domain <- @domains do %>
            <option ><%= domain.name %></option>
          <% end %>
          </select>
        </div>
        <div class="hidden sm:block">
          <nav class="relative z-0 rounded-lg shadow flex divide-x divide-gray-200" aria-label="Tabs">
            <%= for domain <- @domains do %>
              <a phx-click="select_domain" phx-value-id={domain.id} class="text-gray-500 hover:text-gray-700 group relative min-w-0 flex-1 overflow-hidden bg-white py-4 px-4 text-sm font-medium text-center hover:bg-gray-50 focus:z-10" x-state-description="undefined: &quot;text-gray-900&quot;, undefined: &quot;text-gray-500 hover:text-gray-700&quot;">
                <span><%= domain.name %></span>
                <%= if domain.id == @selected_domain do %>
                  <span aria-hidden="true" class="bg-indigo-500 absolute inset-x-0 bottom-0 h-0.5"></span>
                <%= else %>
                  <span aria-hidden="true" class="bg-transparent absolute inset-x-0 bottom-0 h-0.5"></span>
                <% end %>
              </a>
            <% end %>
            </nav>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end
end
