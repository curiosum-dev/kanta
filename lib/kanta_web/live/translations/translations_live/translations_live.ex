defmodule KantaWeb.Translations.TranslationsLive do
  alias Phoenix.LiveView.JS
  alias Kanta.LocaleInfo
  use KantaWeb, :live_view

  # alias KantaWeb.Translations.Components.FiltersBar

  alias KantaWeb.Components.Shared.Pagination

  import KantaWeb.Components.Shared.Table

  # @available_filters ~w(application_source_id domain_id context_id search not_translated page)
  # @available_params ~w(page search filter)
  # @params_in_filter ~w(application_source_id domain_id context_id not_translated)
  # @ids_to_parse ~w(application_source_id domain_id context_id locale_id)

  def mount(_params, session, socket) do
    data_access = session["data_access"]

    socket =
      socket
      |> assign_data_access(data_access)

    {:ok, socket}
  end

  def handle_params(%{"locale_id" => locale_id} = _params, _location, socket) do
    locale_info = LocaleInfo.get_locale_info(locale_id)
    data_access = get_data_access(socket)

    {:ok, {translations, meta}} =
      data_access.list_translations(%{filters: %{locale: locale_id}}, [])

    %{page: page_number, total_pages: total_pages} = meta
    pagination_meta = %{page_number: page_number, total_pages: total_pages}

    {:ok, {domains, _meta}} = data_access.list_resources(:domain, %{}, [])
    {:ok, {contexts, _meta}} = data_access.list_resources(:context, %{}, [])

    domain_colors =
      Map.new(domains, fn domain_metadata -> {domain_metadata.name, domain_metadata.color} end)

    context_colors =
      Map.new(contexts, fn context_metadata -> {context_metadata.name, context_metadata.color} end)

    socket =
      socket
      |> assign(
        locale_info: locale_info,
        translations: translations,
        domain_colors: domain_colors,
        context_colors: context_colors,
        pagination_meta: pagination_meta
      )

    {:noreply, socket}
  end

  def handle_event("change", _filters, socket) do
    # filters = Map.put(filters, "page", "1")
    # query = UriQuery.params(format_filters(Map.merge(socket.assigns.filters, filters)))

    # socket = socket |> assign(:filters, Map.merge(socket.assigns.filters, filters))

    # {:noreply,
    #  push_patch(socket,
    #    to:
    #      "#{dashboard_path(socket)}/locales/#{socket.assigns.locale.id}/translations?" <>
    #        URI.encode_query(query)
    #  )}
    {:noreply, socket}
  end

  def handle_event("navigate", %{"to" => to}, socket) do
    {:noreply, push_navigate(socket, to: dashboard_path(socket) <> to)}
  end

  def handle_event("page_changed", %{"index" => _page_number}, socket) do
    {:noreply, socket}
  end

  defp assign_data_access(socket, data_access), do: assign(socket, data_access: data_access)
  defp get_data_access(socket), do: socket.assigns.data_access

  defp print_msgid(msgid) when is_binary(msgid) do
    case String.length(msgid) > 30 do
      true -> String.slice(msgid, 0..25) <> "[...]"
      _ -> msgid
    end
  end

  defp print_msgid(msgid), do: msgid

  defp print_translation(""), do: "Missing"
  defp print_translation(nil), do: "Missing"
  defp print_translation(msgstr), do: msgstr

  defp print_domain(nil), do: "None"
  defp print_domain(domain_name), do: domain_name

  defp print_context(nil), do: "Default"
  defp print_context(""), do: "Default"
  defp print_context(context_name), do: context_name

  defp lookup_domain_color(nil, _domain_colors),
    do: "transparent"

  defp lookup_domain_color(domain_name, domain_colors) do
    Map.get(domain_colors, domain_name, Kanta.Utils.Colors.default_color()) ||
      Kanta.Utils.Colors.default_color()
  end

  defp lookup_context_color(nil, _context_colors),
    do: "transparent"

  defp lookup_context_color(context_name, context_colors) do
    Map.get(context_colors, context_name, Kanta.Utils.Colors.default_color()) ||
      Kanta.Utils.Colors.default_color()
  end

  defp print_translation_type(%{type: :plural}), do: "Plural"
  defp print_translation_type(_message), do: "Singular"
end
