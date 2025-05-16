defmodule KantaWeb.Components.Shared.Pagination do
  @moduledoc """
  A component for rendering pagination controls with support for page navigation.

  This component displays a pagination interface with previous/next buttons and page numbers.
  It handles edge cases like ellipses for many pages and proper accessibility attributes.
  """

  use Phoenix.Component

  alias KantaWeb.Components.Icons

  # Simple type definitions for pagination entries
  @type page_entry :: {:page, integer()}
  @type ellipsis_entry :: :ellipsis

  attr :metadata, :map,
    required: true,
    doc: "Pagination metadata with :page_number and :total_pages keys"

  attr :on_page_change, :any, required: true, doc: "Event to trigger when changing pages"

  attr :surrounding_pages_number, :integer,
    default: 4,
    doc: "Number of page links to show around current page"

  def render(
        %{
          metadata: %{page_number: p_num, total_pages: total_pages}
        } = assigns
      )
      when is_integer(p_num) and p_num > 0 and is_integer(total_pages) and total_pages >= 0 do
    assigns = assign(assigns, current_page: p_num, total_pages: total_pages)

    ~H"""
    <nav aria-label="Pagination" class="border-t border-gray-200 px-4 mb-4 flex items-center justify-between sm:px-0">
      <div class="-mt-px w-0 flex-1 flex">
        <button
          type="button"
          phx-click={@on_page_change}
          phx-value-index={@current_page - 1}
          disabled={@current_page == 1}
          aria-label="Previous page"
          class={[
            navigation_button_class(),
            if(@current_page == 1, do: disabled_class(), else: enabled_class())
          ]}
        >
          <Icons.arrow_left class="mr-3 h-5 w-5" />
          Previous
        </button>
      </div>
      <div class="hidden md:-mt-px md:flex">
        <%= for entry <- calculate_pages(@current_page, @total_pages, @surrounding_pages_number) do %>
          <%= case entry do %>
            <% {:page, page_number} -> %>
              <button
                type="button"
                phx-click={@on_page_change}
                phx-value-index={page_number}
                aria-label={"Page #{page_number}"}
                aria-current={if page_number == @current_page, do: "page", else: "false"}
                class={
                  if page_number == @current_page, do: active_page_class(), else: inactive_page_class()
                }
              >
                <%= page_number %>
              </button>
            <% :ellipsis -> %>
              <span class="border-transparent text-gray-500 dark:text-content-light/80 border-t-2 pt-4 px-4 inline-flex items-center text-sm font-medium" aria-hidden="true">…</span>
          <% end %>
        <% end %>
      </div>
      <div class="-mt-px w-0 flex-1 flex justify-end">
        <button
          type="button"
          phx-click={@on_page_change}
          phx-value-index={@current_page + 1}
          disabled={@current_page == @total_pages}
          aria-label="Next page"
          class={[
            navigation_button_class(),
            if(@current_page == @total_pages, do: disabled_class(), else: enabled_class())
          ]}
        >
          Next
          <Icons.arrow_right class="ml-3 h-5 w-5" />
        </button>
      </div>
    </nav>
    """
  end

  @doc """
  Calculates the sequence of page numbers and ellipses to display in the pagination component.

  Returns a list of entries, where each entry is either:
  - {:page, n} - A page number to display
  - :ellipsis - An ellipsis indicating skipped pages
  """
  @spec calculate_pages(integer(), integer(), integer()) :: [page_entry | ellipsis_entry]
  def calculate_pages(current_page, total_pages, _surrounding) when total_pages <= 1 do
    [{:page, current_page}]
  end

  def calculate_pages(current_page, total_pages, surrounding) do
    # Define the middle range that always includes the current page
    start_middle = max(current_page - surrounding, 2)
    end_middle = min(current_page + surrounding, total_pages - 1)

    # Generate the complete list of entries in a single pass
    []
    |> add_first_page()
    |> add_start_ellipsis(start_middle)
    |> add_middle_pages(start_middle, end_middle)
    |> add_end_ellipsis(end_middle, total_pages)
    |> add_last_page(total_pages)
    # Remove any nil entries
    |> Enum.filter(fn x -> x != nil end)
  end

  defp add_first_page(list), do: list ++ [{:page, 1}]

  defp add_start_ellipsis(list, start_middle) when start_middle > 2, do: list ++ [:ellipsis]
  defp add_start_ellipsis(list, _), do: list

  defp add_middle_pages(list, start_middle, end_middle) when start_middle <= end_middle do
    middle_pages = Enum.map(start_middle..end_middle, &{:page, &1})
    list ++ middle_pages
  end

  defp add_middle_pages(list, _, _), do: list

  defp add_end_ellipsis(list, end_middle, total_pages) when end_middle < total_pages - 1,
    do: list ++ [:ellipsis]

  defp add_end_ellipsis(list, _, _), do: list

  # Don't add last page if total_pages is 1
  defp add_last_page(list, 1), do: list
  defp add_last_page(list, total_pages), do: list ++ [{:page, total_pages}]

  # Helper functions for CSS classes
  defp active_page_class do
    "border-primary-dark dark:border-accent-dark text-primary-dark dark:text-accent-dark border-t-2 pt-4 px-4 inline-flex items-center text-sm font-medium cursor-pointer"
  end

  defp inactive_page_class do
    "border-transparent text-gray-500 dark:text-content-light/80 hover:text-gray-700 hover:dark:text-white hover:border-gray-300 border-t-2 pt-4 px-4 inline-flex items-center text-sm font-medium cursor-pointer"
  end

  defp navigation_button_class do
    "border-t-2 border-transparent pt-4 pr-1 inline-flex items-center text-sm font-medium text-gray-500 dark:text-content-light"
  end

  defp disabled_class do
    "pointer-events-none opacity-20"
  end

  defp enabled_class do
    "opacity-100 cursor-pointer hover:text-gray-700 hover:dark:text-white hover:border-gray-300"
  end
end
