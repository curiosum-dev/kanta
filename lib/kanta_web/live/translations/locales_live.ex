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
              <div phx-click="navigate" phx-value-to={Routes.translation_path(@socket, :index, locale.id)} class="bg-white overflow-hidden shadow rounded-lg cursor-pointer">
                <div class="px-4 py-5 sm:p-6 font-medium text-md text-slate-700">
                  <%= locale.name %>
                </div>
              </div>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    locales = Translations.list_locales()

    {:ok,
     socket
     |> assign(:locales, locales)}
  end

  def handle_event("navigate", %{"to" => to}, socket) do
    {:noreply, push_redirect(socket, to: "/kanta" <> to)}
  end
end
