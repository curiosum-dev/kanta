defmodule KantaWeb.Translations.LocalesLive do
  use KantaWeb, :live_view

  alias Kanta.Translations

  def render(assigns) do
    ~H"""
    <h1 class="font-semibold text-md text-slate-900">
      Languages
    </h1>
    <div class="flex flex-col justify-start items-start">
      <%= for locale <- @locales do %>
        <div class="bg-gray-100 my-2 w-full">
          <div class="max-w-7xl">
            <div class="max-w-2xl">
              <.link patch={path(@socket, ~p"/kanta/locales/#{locale.id}/translations")}>
                <div class="bg-white overflow-hidden shadow rounded-lg cursor-pointer">
                  <div class="px-4 py-5 sm:p-6 font-medium text-md text-slate-700">
                    <%= locale.name %>
                  </div>
                </div>
              </.link>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  def mount(params, session, socket) do
    locales = Translations.list_locales()

    {:ok,
     socket
     |> assign(:locales, locales)}
  end
end
