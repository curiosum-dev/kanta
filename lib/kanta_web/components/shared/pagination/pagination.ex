defmodule KantaWeb.Components.Shared.Pagination do
  @moduledoc """
  Shared pagination component
  """

  use Phoenix.Component

  alias KantaWeb.Components.Icons

  def render(assigns) do
    ~H"""
      <nav class="border-t border-gray-200 px-4 mb-4 flex items-center justify-between sm:px-0">
        <div class="-mt-px w-0 flex-1 flex">
          <a
            phx-click={@on_page_change}
            phx-value-index={@metadata[:page_number] - 1}
            class={[
              "#{if @metadata[:page_number] == 1, do: "pointer-events-none opacity-20", else: "opacity-100 cursor-pointer hover:text-gray-700 hover:dark:text-white hover:border-gray-300"}",
              "border-t-2 border-transparent pt-4 pr-1 inline-flex items-center text-sm font-medium text-gray-500 dark:text-content-light",
            ]}
          >
            <Icons.arrow_left class="mr-3 h-5 w-5" />
            Previous
          </a>
        </div>
        <div class="hidden md:-mt-px md:flex">
          <a
            phx-click={@on_page_change}
            phx-value-index={1}
            class={
              if 1 == @metadata[:page_number], do: "border-primary-dark dark:border-accent-dark text-primary-dark dark:text-accent-dark border-t-2 pt-4 px-4 inline-flex items-center text-sm font-medium cursor-pointer", else: "border-transparent text-gray-500 dark:text-content-light/80 hover:text-gray-700 hover:dark:text-white hover:border-gray-300 border-t-2 pt-4 px-4 inline-flex items-center text-sm font-medium cursor-pointer"
            }
          >
            1
          </a>
          <%= if @metadata[:page_number] > 6 do %>
            <span class="border-transparent text-gray-500 dark:text-content-light/80 border-t-2 pt-4 px-4 inline-flex items-center text-sm font-medium">...</span>
          <% end %>
          <%= for page <- max(2, @metadata[:page_number] - 4)..min(@metadata[:total_pages] - 1, @metadata[:page_number] + 4) do %>
            <a
              phx-click={@on_page_change}
              phx-value-index={page}
              class={
                if page == @metadata[:page_number], do: "border-primary-dark dark:border-accent-dark text-primary-dark dark:text-accent-dark border-t-2 pt-4 px-4 inline-flex items-center text-sm font-medium cursor-pointer", else: "border-transparent text-gray-500 dark:text-content-light/80 hover:text-gray-700 hover:dark:text-white hover:border-gray-300 border-t-2 pt-4 px-4 inline-flex items-center text-sm font-medium cursor-pointer"
              }
            >
              <%= page %>
            </a>
          <% end %>
          <%= if @metadata[:page_number] < @metadata[:total_pages] - 5 do %>
            <span class="border-transparent text-gray-500 dark:text-content-light/80 border-t-2 pt-4 px-4 inline-flex items-center text-sm font-medium">...</span>
          <% end %>
          <a
            phx-click={@on_page_change}
            phx-value-index={@metadata[:total_pages]}
            class={
              if @metadata[:total_pages] == @metadata[:page_number], do: "border-primary-dark dark:border-accent-dark text-primary-dark dark:text-accent-dark border-t-2 pt-4 px-4 inline-flex items-center text-sm font-medium cursor-pointer", else: "border-transparent text-gray-500 dark:text-content-light/80 hover:text-gray-700 hover:dark:text-white hover:border-gray-300 border-t-2 pt-4 px-4 inline-flex items-center text-sm font-medium cursor-pointer"
            }
          >
            <%= @metadata[:total_pages] %>
          </a>
        </div>
        <div class="-mt-px w-0 flex-1 flex justify-end">
          <a phx-click={@on_page_change} phx-value-index={@metadata[:page_number] + 1}
          class={[
              "#{if @metadata[:page_number] == @metadata[:total_pages], do: "pointer-events-none opacity-20", else: "opacity-100 cursor-pointer hover:text-gray-700 hover:dark:text-white hover:border-gray-300"}",
              "border-t-2 border-transparent pt-4 pr-1 inline-flex items-center text-sm font-medium text-gray-500 dark:text-content-light",
            ]}
          >
            Next
            <Icons.arrow_right class="ml-3 h-5 w-5" />
          </a>
        </div>
      </nav>
    """
  end
end
