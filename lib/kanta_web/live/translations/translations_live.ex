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

  def mount(%{"locale_id" => locale_id}, _session, socket) do
    locale = Translations.get_locale(locale_id)
    domains = Translations.list_domains() || []

    messages =
      Translations.list_messages_by(%{"filter" => %{"domain_id" => List.first(domains).id}}) || []

    socket =
      socket
      |> assign(:locale, locale)
      |> assign(:domains, domains)
      |> assign(:messages, messages)
      |> assign(:selected_domain, List.first(domains).id)

    {:ok, socket}
  end

  def handle_event("select_domain", %{"id" => id}, socket) do
    messages = Translations.list_messages_by(%{"filter" => %{"domain_id" => id}}) || []

    socket =
      socket
      |> assign(:selected_domain, id)
      |> assign(:messages, messages)

    {:noreply, socket}
  end

  def handle_event("navigate", %{"to" => to}, socket) do
    {:noreply, push_redirect(socket, to: "/kanta" <> to)}
  end
end
