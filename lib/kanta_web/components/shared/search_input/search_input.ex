defmodule KantaWeb.Components.Shared.SearchInput do
  @moduledoc """
  Simple search input component
  """

  use Phoenix.Component

  alias KantaWeb.Components.Icons

  attr :label, :string, required: true
  attr :name, :any
  attr :value, :any
  attr :rest, :global

  def render(assigns) do
    ~H"""
    <div>
      <label class="block text-sm font-medium text-gray-700 dark:text-content-light">
        <%= @label %>
      </label>
      <div class="relative mt-1">
        <input
          name={@name}
          value={@value}
          style="min-width: 18rem;"
          class={[
            "font-medium text-base-content py-2 pl-4 pr-2 shadow-sm bg-white dark:bg-stone-900 text-stone-900 dark:text-content-light border border-gray-300 focus:outline-none focus:ring-primary focus:dark:ring-accent-dark focus:border-primary focus:dark:border-accent-dark block w-full sm:text-sm rounded-md"
          ]}
          {@rest}
        />
        <span class="absolute inset-y-0 right-0 flex items-center pr-2 ml-3 pointer-events-none">
          <Icons.search class="h-4 w-4 text-gray-300" />
        </span>
      </div>
    </div>
    """
  end
end
