defmodule KantaWeb.Translations.TranslationsLive do
  use KantaWeb, :live_view

  alias Kanta.Translations
  alias KantaWeb.Translations.Components.{FiltersBar, MessagesTable}

  alias KantaWeb.Components.Shared.Pagination

  @available_filters ~w(domain_id context_id search not_translated page)

  def mount(%{"locale_id" => locale_id}, _session, socket) do
    socket =
      with {:ok, locale} <- Translations.get_locale(filter: [id: locale_id]) do
        socket
        |> assign(:locale, locale)
        |> assign(:filters, %{})
      else
        _ ->
          socket
      end

    {:ok, socket}
  end

  def handle_params(%{"locale_id" => locale_id} = params, _location, socket) do
    %{entries: messages, metadata: messages_metadata} =
      Translations.list_messages(
        []
        |> Keyword.merge(filter: Map.put(params["filter"] || %{}, "locale_id", locale_id))
        |> Keyword.merge(search: params["search"] || "")
        |> Keyword.merge(page: params["page"] || "1")
        |> Keyword.merge(
          preloads: [
            :context,
            :domain,
            :singular_translations,
            :plural_translations
          ]
        )
      )

    socket =
      socket
      |> assign(:messages, messages)
      |> assign(:messages_metadata, messages_metadata)

    {:noreply, socket}
  end

  def handle_event("change", filters, socket) do
    query = UriQuery.params(format_filters(Map.merge(socket.assigns.filters, filters)))

    socket = socket |> assign(:filters, Map.merge(socket.assigns.filters, filters))

    {:noreply,
     push_patch(socket,
       to:
         "/kanta/locales/#{socket.assigns.locale.id}/translations?" <>
           URI.encode_query(query)
     )}
  end

  defp format_filters(filters) do
    filters
    |> Map.take(@available_filters)
    |> Enum.reject(fn {_, value} -> is_nil(value) or value == "" end)
    |> Enum.reduce([filter: %{}, search: "", page: "1"], fn {key, value}, acc ->
      case key do
        "search" ->
          Keyword.put(acc, :search, value)

        "page" ->
          Keyword.put(acc, :page, value)

        "not_translated" ->
          Keyword.put(
            acc,
            :filter,
            Map.put(acc[:filter] || %{}, "not_translated", value)
          )

        filter_key ->
          Keyword.put(
            acc,
            :filter,
            Map.put(acc[:filter] || %{}, filter_key, String.to_integer(value))
          )
      end
    end)
  end

  def handle_event("navigate", %{"to" => to}, socket) do
    {:noreply, push_redirect(socket, to: "/kanta" <> to)}
  end

  def handle_event("page_changed", %{"index" => page_number}, socket) do
    socket =
      socket
      |> assign(
        :filters,
        Map.merge(socket.assigns.filters, %{"page" => String.to_integer(page_number)})
      )

    query =
      UriQuery.params(
        format_filters(
          Map.merge(socket.assigns.filters, %{"page" => String.to_integer(page_number)})
        )
      )

    {:noreply,
     push_patch(socket,
       to:
         "/kanta/locales/#{socket.assigns.locale.id}/translations?" <>
           URI.encode_query(query)
     )}
  end
end
