defmodule KantaWeb.Translations.TranslationsLive do
  use KantaWeb, :live_view

  import Kanta.Utils.ParamParsers

  alias Kanta.Translations
  alias Kanta.Translations.SingularTranslations.Finders.ListSingularTranslations
  alias Kanta.Translations.PluralTranslations.Finders.ListPluralTranslations
  alias KantaWeb.Translations.Components.{FiltersBar, MessagesTable}

  alias KantaWeb.Components.Shared.Pagination

  @available_filters ~w(domain_id context_id search not_translated page)
  @available_params ~w(page search filter)
  @params_in_filter ~w(domain_id context_id not_translated)
  @ids_to_parse ~w(domain_id context_id locale_id)

  def mount(%{"locale_id" => locale_id} = params, _session, socket) do
    socket =
      case get_locale(locale_id) do
        {:ok, locale} ->
          socket
          |> assign(:locale, locale)
          |> assign(:filters, %{})
          |> assign(get_assigns_from_params(params))

        _ ->
          socket
          |> redirect(to: "/kanta/locales")
      end

    {:ok, socket}
  end

  def handle_params(%{"locale_id" => locale_id} = params, _location, socket) do
    preload_filters = %{"locale_id" => locale_id}
    singular_translation_query = ListSingularTranslations.filter_query(preload_filters)
    plural_translation_query = ListPluralTranslations.filter_query(preload_filters)

    %{entries: messages, metadata: messages_metadata} =
      Translations.list_messages(
        []
        |> Keyword.merge(search: params["search"] || "")
        |> Keyword.merge(page: parse_page(params["page"] || "1"))
        |> Keyword.merge(
          filter: parse_filters(Map.put(params["filter"] || %{}, "locale_id", locale_id))
        )
        |> Keyword.merge(
          preloads: [
            :context,
            :domain,
            singular_translations: singular_translation_query,
            plural_translations: plural_translation_query
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
    filters = Map.put(filters, "page", "1")
    query = UriQuery.params(format_filters(Map.merge(socket.assigns.filters, filters)))

    socket = socket |> assign(:filters, Map.merge(socket.assigns.filters, filters))

    {:noreply,
     push_patch(socket,
       to:
         "#{dashboard_path(socket)}/locales/#{socket.assigns.locale.id}/translations?" <>
           URI.encode_query(query)
     )}
  end

  def handle_event("navigate", %{"to" => to}, socket) do
    {:noreply, push_redirect(socket, to: dashboard_path(socket) <> to)}
  end

  def handle_event("page_changed", %{"index" => page_number}, socket) do
    socket =
      socket
      |> assign(
        :filters,
        Map.merge(socket.assigns.filters, %{"page" => parse_page(page_number)})
      )

    query =
      UriQuery.params(
        format_filters(Map.merge(socket.assigns.filters, %{"page" => parse_page(page_number)}))
      )

    {:noreply,
     push_patch(socket,
       to:
         "#{dashboard_path(socket)}/locales/#{socket.assigns.locale.id}/translations?" <>
           URI.encode_query(query)
     )}
  end

  defp get_locale(id) do
    case parse_id_filter(id) do
      {:ok, id} -> Translations.get_locale(filter: [id: id])
      _ -> {:error, :id, :invalid}
    end
  end

  defp format_filters(filters) do
    filters
    |> Map.take(@available_filters)
    |> Enum.reject(fn {_, value} -> is_nil(value) or value == "" end)
    |> Enum.reduce([filter: %{}, search: "", page: "1"], &update_filters_acc/2)
  end

  defp update_filters_acc({"search", value}, acc), do: Keyword.put(acc, :search, value)
  defp update_filters_acc({"page", value}, acc), do: Keyword.put(acc, :page, value)

  defp update_filters_acc({"not_translated", value}, acc) do
    Keyword.put(acc, :filter, Map.put(acc[:filter] || %{}, "not_translated", value))
  end

  defp update_filters_acc({key, value}, acc) do
    case parse_id_filter(value) do
      {:ok, id} -> Keyword.put(acc, :filter, Map.put(acc[:filter] || %{}, key, id))
      _ -> acc
    end
  end

  defp get_assigns_from_params(params) do
    params
    |> Map.take(@available_params)
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      case key do
        "filter" ->
          values = Map.take(value, @params_in_filter)
          Map.merge(acc, values)

        filter_key ->
          Map.put(acc, filter_key, value)
      end
    end)
    |> then(fn filters ->
      %{
        not_translated_default: get_not_translated_default_value(params),
        filters: filters
      }
    end)
  end

  defp get_not_translated_default_value(%{"filter" => filter}) do
    case filter["not_translated"] do
      "true" -> true
      _ -> false
    end
  end

  defp get_not_translated_default_value(_), do: false

  defp parse_filters(filters) do
    Enum.reduce(filters, %{}, &parse_filter/2)
  end

  defp parse_filter({key, value}, acc) when key in @ids_to_parse do
    case parse_id_filter(value) do
      {:ok, id} -> Map.put(acc, key, id)
      _ -> acc
    end
  end

  defp parse_filter({key, value}, acc) do
    Map.put(acc, key, value)
  end
end
