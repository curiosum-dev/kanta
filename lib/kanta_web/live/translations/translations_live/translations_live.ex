defmodule KantaWeb.Translations.TranslationsLive do
  @moduledoc """
  LiveView for displaying and managing translations across different locales.
  Provides functionality for filtering, sorting, and paginating translations.
  """
  alias Kanta.DataAccess.Model.Plural
  alias Kanta.LocaleInfo
  alias Kanta.Utils.Colors
  alias KantaWeb.Components.Shared.Pagination
  alias Phoenix.LiveView.JS
  use KantaWeb, :live_view

  import KantaWeb.Components.Shared.Table

  @type list_params :: %{
          filters: map(),
          pagination: map(),
          sort: {atom(), atom()},
          search_text: String.t() | nil
        }

  @default_page_size 10
  @default_sort_by :msgid
  @default_sort_order :asc

  @default_options %{
    locale: nil,
    page: nil,
    page_size: nil,
    sort_by: nil,
    sort_order: nil,
    domain: nil,
    context: nil,
    search: nil,
    translated_only?: false
  }

  @allowed_options_keys Map.keys(@default_options)

  @doc """
  Initializes the LiveView with data access and empty translations.
  """
  def mount(_params, session, socket) do
    socket =
      socket
      |> assign_data_access(session["data_access"])

    {:ok, socket, temporary_assigns: [translations: [], domain_colors: %{}, context_colors: %{}]}
  end

  @doc """
  Handles URL parameters and loads translations and associated metadata.
  """
  def handle_params(%{"locale_id" => locale_id} = params, _location, socket) do
    data_access = get_data_access(socket)
    # LiveView options ex. sort field, page to display
    options = options_from_query_params(params)

    data_access_params =
      options_to_data_access_params(options)

    # Get translations
    {:ok, {translations, meta}} = data_access.list_translations(data_access_params, [])

    # Set Pagination component format
    %{page: page_number, total_pages: total_pages} = meta
    pagination_meta = %{page_number: page_number, total_pages: total_pages}

    # Get metadata for displaying colors in the dashboard
    domain_colors = get_domain_colors(data_access)
    context_colors = get_context_colors(data_access)

    # Geta borader information abiut the locale (language name, flag)
    locale_info = LocaleInfo.get_locale_info(locale_id)

    socket =
      socket
      |> assign(
        locale_info: locale_info,
        translations: translations,
        domain_colors: domain_colors,
        context_colors: context_colors,
        pagination_meta: pagination_meta,
        options: options
      )

    {:noreply, socket}
  end

  @doc """
  Handles filter changes and updates the URL accordingly.
  """
  def handle_event("change", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("navigate", %{"to" => to}, socket) do
    {:noreply, push_navigate(socket, to: dashboard_path(socket) <> to)}
  end

  def handle_event("page_changed", %{"index" => page_number}, socket) do
    page = String.to_integer(page_number)
    updated_options = update_options(socket.assigns.options, :page, page)

    path =
      build_translation_url(socket, updated_options)

    socket =
      socket
      |> assign(options: updated_options)
      |> push_patch(to: path)

    {:noreply, socket}
  end

  def handle_event("edit_message", %{"id" => _id, "type" => _type}, socket) do
    # Placeholder for future message editing functionality
    # This would typically navigate to an edit form or open a modal
    {:noreply, socket}
  end

  # Private helper functions
  #
  defp build_translation_url(socket, options) do
    query_params =
      options
      |> options_to_query_params()
      |> URI.encode_query()

    dashboard_path(
      socket,
      "/locales/#{options.locale}/translations?#{query_params}"
    )
  end

  defp update_options(opts, key, value) when is_map(opts) and key in @allowed_options_keys do
    Map.put(opts, key, value)
  end

  defp assign_data_access(socket, data_access), do: assign(socket, data_access: data_access)

  defp get_data_access(socket), do: socket.assigns.data_access

  defp get_domain_colors(data_access) do
    {:ok, {domains, _meta}} = data_access.list_resources(:domain, %{}, [])
    Map.new(domains, fn domain_metadata -> {domain_metadata.name, domain_metadata.color} end)
  end

  defp get_context_colors(data_access) do
    {:ok, {contexts, _meta}} = data_access.list_resources(:context, %{}, [])
    Map.new(contexts, fn context_metadata -> {context_metadata.name, context_metadata.color} end)
  end

  # defp maybe_update_filter(filters, _key, nil), do: filters
  # defp maybe_update_filter(filters, key, ""), do: Map.delete(filters, key)
  # defp maybe_update_filter(filters, key, value), do: Map.put(filters, key, value)

  # Display helpers

  defp print_msgid(msgid) when is_binary(msgid) do
    if String.length(msgid) > 30, do: String.slice(msgid, 0..25) <> "[...]", else: msgid
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

  defp lookup_domain_color(nil, _domain_colors), do: "transparent"

  defp lookup_domain_color(domain_name, domain_colors) do
    Map.get(domain_colors, domain_name) || Colors.default_color()
  end

  defp lookup_context_color(nil, _context_colors), do: "transparent"

  defp lookup_context_color(context_name, context_colors) do
    Map.get(context_colors, context_name) || Colors.default_color()
  end

  defp print_translation_type(%Plural{}), do: "Plural"
  defp print_translation_type(_message), do: "Singular"

  # Query parameter c
  # onversion

  @spec options_from_query_params(map()) :: map()
  defp options_from_query_params(params) do
    %{
      @default_options
      | locale: params["locale_id"],
        page: (params["page"] || "1") |> String.to_integer(),
        page_size: (params["page_size"] || to_string(@default_page_size)) |> String.to_integer(),
        sort_by: (params["sort_by"] || "msgid") |> String.to_existing_atom(),
        sort_order: (params["sort_order"] || "asc") |> String.to_existing_atom(),
        domain: params["domain"],
        context: params["context"],
        search: params["search"],
        translated_only?: params["translated_only"] || false
    }
  end

  defp options_to_data_access_params(opts) when is_map(opts) do
    sort = {opts.sort_by, opts.sort_order}

    filters =
      %{domain: opts.domain, msgctxt: opts.context, locale: opts.locale}
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> then(fn filters ->
        if opts.translated_only?, do: [{:msgstr, nil} | filters], else: filters
      end)
      |> then(fn filters ->
        if is_nil(opts.search) || (is_binary(opts.search) && String.trim(opts.search) == ""),
          do: filters,
          else: [{:search_text, opts.search} | filters]
      end)
      |> Map.new()

    pagination = %{type: :page, page: opts.page, size: opts.page_size}

    %{filters: filters, sort: sort, pagination: pagination}
  end

  @spec options_to_query_params(map()) :: map()
  defp options_to_query_params(options) do
    %{
      page: page,
      page_size: page_size,
      sort_by: sort_by,
      sort_order: sort_order,
      domain: domain,
      context: context,
      search: search_text,
      translated_only?: translated_only?
    } = options

    params = %{
      "sort_by" => sort_by,
      "sort_order" => sort_order,
      "page" => page,
      "page_size" => page_size,
      "search" => search_text,
      "domain" => domain,
      "context" => context,
      "translated_only" => translated_only?
    }

    params
    |> Map.reject(fn
      {"sort_by", @default_sort_by} -> true
      {"sort_order", @default_sort_order} -> true
      {"page_size", @default_page_size} -> true
      {"page", 1} -> true
      {"search", ""} -> true
      {"search", nil} -> true
      {"translated_only", false} -> true
      {_k, v} -> is_nil(v)
    end)
  end

  # Table header helpers

  defp header_label(
         description,
         field,
         %{sort_by: current_sort_by, sort_order: current_sort_order} = options,
         socket
       ) do
    sort_order = calculate_new_sort_order(current_sort_by, field, current_sort_order)
    sort_indicator = sort_indicator(sort_order)

    updated_options = %{options | sort_by: field, sort_order: sort_order}

    assigns = %{
      description: description,
      sort_indicator: sort_indicator,
      path: build_translation_url(socket, updated_options)
    }

    ~H"""
     <.link patch={@path}>
      <span><%= @description %></span>
      <%= @sort_indicator %>
    </.link>
    """
  end

  defp sort_indicator(:asc), do: "▲"
  defp sort_indicator(:desc), do: "▼"

  defp calculate_new_sort_order(current_column, target_column, current_order)
       when current_column == target_column do
    case current_order do
      :asc -> :desc
      :desc -> :asc
    end
  end

  defp calculate_new_sort_order(_, _, _), do: :desc
end
