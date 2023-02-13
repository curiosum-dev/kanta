defmodule KantaWeb.Translations.TranslationsLive do
  use KantaWeb, :live_view

  alias Kanta.Translations
  alias KantaWeb.Translations.{DomainsTabBar, MessagesTable}

  def render(assigns) do
    ~H"""
    <div>
      <.live_component module={DomainsTabBar} id="tab-bar" domains={@domains} selected_domain={@selected_domain} />
      <.live_component module={MessagesTable} id="messages-table" messages={@messages} locale={@locale} />
    </div>
    """
  end

  def mount(_params, %{"locale_id" => locale_id}, socket) do
    locale = Translations.get_locale(locale_id)
    domains = Translations.list_domains() || []
    messages = Translations.list_messages_by_domain(List.first(domains).id) || []

    socket =
      socket
      |> assign(:locale, locale)
      |> assign(:domains, domains)
      |> assign(:messages, messages)
      |> assign(:selected_domain, List.first(domains).id)

    {:ok, socket}
  end

  def handle_event("select_domain", %{"id" => id}, socket) do
    messages = Translations.list_messages_by_domain(id)

    socket =
      socket
      |> assign(:selected_domain, id)
      |> assign(:messages, messages)

    {:noreply, socket}
  end

  def handle_event("navigate", %{"to" => to}, socket) do
    {:noreply, push_redirect(socket, to: "/kanta" <> to)}
  end

  defp group_translations_by_domains(translations) do
    translations
    |> Enum.group_by(&elem(&1, 1))
  end

  defp sort_translations(translations) do
    {empty_translations, filled_translations} =
      translations
      |> Enum.reduce({[], []}, fn translation, {empty, filled} ->
        case elem(translation, 4) === "" do
          true -> {[translation] ++ empty, filled}
          false -> {empty, [translation] ++ filled}
        end
      end)

    empty_translations ++ filled_translations
  end
end
