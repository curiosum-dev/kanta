defmodule KantaWeb.Translations.TranslationsLive do
  use KantaWeb, :live_view

  alias Kanta.Translations
  alias KantaWeb.Translations.MessagesTable

  alias KantaWeb.Components.Shared.Pagination

  def mount(%{"locale_id" => locale_id}, _session, socket) do
    socket =
      with {:ok, locale} <- Translations.get_locale(filter: [id: locale_id]),
           %{entries: messages, metadata: messages_metadata} <-
             Translations.list_messages(
               preloads: [
                 :context,
                 :domain,
                 :singular_translations,
                 :plural_translations
               ]
             ) do
        socket
        |> assign(:locale, locale)
        |> assign(:messages, messages)
        |> assign(:messages_metadata, messages_metadata)
      else
        _ ->
          socket
      end

    {:ok, socket}
  end

  def handle_event("navigate", %{"to" => to}, socket) do
    {:noreply, push_redirect(socket, to: "/kanta" <> to)}
  end

  def handle_event("page_changed", %{"index" => page_number}, socket) do
    %{entries: messages, metadata: messages_metadata} =
      Translations.list_messages(
        page: String.to_integer(page_number),
        preloads: [:context, :domain, :singular_translations, :plural_translations]
      )

    socket =
      socket
      |> assign(:messages, messages)
      |> assign(:messages_metadata, messages_metadata)

    {:noreply, socket}
  end
end
