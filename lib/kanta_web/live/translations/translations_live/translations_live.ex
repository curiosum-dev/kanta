defmodule KantaWeb.Translations.TranslationsLive do
  @moduledoc """
  LiveView for displaying and managing translations across different locales.
  Provides functionality for filtering, sorting, and paginating translations.
  """

  alias Kanta.DataAccess.Model.Plural
  alias Kanta.DataAccess.Model.Plurals
  alias Kanta.DataAccess.Model.Singular
  alias Phoenix.LiveView.Socket
  alias Kanta.DataAccess
  alias Kanta.LocaleInfo
  alias Kanta.Utils.Colors
  alias KantaWeb.Components.Shared.Pagination
  alias Phoenix.LiveView.JS
  use KantaWeb, :live_view

  import KantaWeb.Components.Shared.Table

  # ----------------------------------------------------------------------------
  # Typesepcs
  # ----------------------------------------------------------------------------

  @type options :: %{
          locale: String.t() | nil,
          page: pos_integer(),
          page_size: pos_integer(),
          sort_by: atom(),
          sort_order: :asc | :desc,
          domain: String.t() | nil,
          context: String.t() | nil,
          search: String.t() | nil,
          not_translated: boolean()
        }

  # ----------------------------------------------------------------------------
  # Default values (attributes)
  # ----------------------------------------------------------------------------

  @default_page_size 10
  @default_sort_by :msgid
  # Default sort order for initial load and when toggling
  @default_sort_order :asc

  @default_options %{
    locale: nil,
    page: 1,
    page_size: @default_page_size,
    sort_by: @default_sort_by,
    sort_order: @default_sort_order,
    domain: nil,
    context: nil,
    search: nil,
    not_translated: false
  }

  @allowed_options_keys Map.keys(@default_options)

  # ----------------------------------------------------------------------------
  # LiveView Callbacks
  # ----------------------------------------------------------------------------

  @impl true
  def mount(_params, session, socket) do
    socket =
      socket
      |> assign_data_access(session["data_access"])

    {:ok, socket, temporary_assigns: [translations: [], domain_colors: %{}, context_colors: %{}]}
  end

  @impl true
  def handle_params(%{"locale_id" => _locale_id} = params, _uri, socket) do
    data_access = get_data_access(socket)
    options = parse_view_options(params)
    data_access_params = build_data_access_params(options)

    live_data = fetch_live_data(data_access, options, data_access_params)

    socket =
      socket
      |> assign_common_data(options, live_data)

    {:noreply, socket}
  end

  @impl true
  def handle_event("change", _params, socket) do
    # This event can be used for form changes that don't immediately repatch,
    # for example, if you add live text input filters.
    {:noreply, socket}
  end

  @impl true
  def handle_event("navigate", %{"to" => to}, socket) do
    {:noreply, push_navigate(socket, to: dashboard_path(socket) <> to)}
  end

  @impl true
  def handle_event("page_changed", %{"index" => page_number_str}, socket) do
    page = String.to_integer(page_number_str)
    # Ensure current options are taken from assigns, not potentially stale closure
    current_options = socket.assigns.options
    updated_options = update_options(current_options, :page, page)

    path = build_translation_url(socket, updated_options)

    socket =
      socket
      |> assign(:options, updated_options)
      |> push_patch(to: path)

    {:noreply, socket}
  end

  @impl true
  def handle_event("edit_message", %{"id" => _id, "type" => _type}, socket) do
    # Placeholder for future message editing functionality
    # This would typically navigate to an edit form or open a modal
    # IO.inspect(%{message_id: _id, type: _type}, label: "Edit Message Event")
    {:noreply, socket}
  end

  # ----------------------------------------------------------------------------
  # Private Helper Functions
  # ----------------------------------------------------------------------------

  # --- Data Access and Assignment Helpers ---

  defp assign_data_access(socket, data_access), do: assign(socket, :data_access, data_access)

  defp get_data_access(socket), do: socket.assigns.data_access

  defp update_options(opts, key, value) when is_map(opts) and key in @allowed_options_keys do
    Map.put(opts, key, value)
  end

  # --- Data Loading Helpers ---

  defp fetch_live_data(data_access, options, data_access_params) do
    {:ok, {translations, meta}} = data_access.list_translations(data_access_params, [])
    dbg(translations)
    domain_colors = get_domain_colors(data_access)
    context_colors = get_context_colors(data_access)
    locale_info = LocaleInfo.get_locale_info(options.locale)

    %{
      translations: translations,
      pagination_meta: %{page_number: meta.page, total_pages: meta.total_pages},
      domain_colors: domain_colors,
      context_colors: context_colors,
      locale_info: locale_info
    }
  end

  defp assign_common_data(socket, options, live_data) do
    assign(socket,
      options: options,
      translations: live_data.translations,
      pagination_meta: live_data.pagination_meta,
      domain_colors: live_data.domain_colors,
      context_colors: live_data.context_colors,
      locale_info: live_data.locale_info
    )
  end

  defp get_domain_colors(data_access) do
    {:ok, {domains, _meta}} = data_access.list_resources(:domain, %{}, [])
    Map.new(domains, fn domain_metadata -> {domain_metadata.name, domain_metadata.color} end)
  end

  defp get_context_colors(data_access) do
    {:ok, {contexts, _meta}} = data_access.list_resources(:context, %{}, [])
    Map.new(contexts, fn context_metadata -> {context_metadata.name, context_metadata.color} end)
  end

  # --- Option & Parameter Conversion ---

  @spec parse_view_options(map()) :: options()
  defp parse_view_options(params) do
    %{
      @default_options
      | locale: params["locale_id"],
        page: (params["page"] || "1") |> String.to_integer(),
        page_size: (params["page_size"] || to_string(@default_page_size)) |> String.to_integer(),
        sort_by:
          (params["sort_by"] || Atom.to_string(@default_sort_by)) |> String.to_existing_atom(),
        sort_order:
          (params["sort_order"] || Atom.to_string(@default_sort_order))
          |> String.to_existing_atom(),
        domain: params["domain"],
        context: params["context"],
        search: params["search"],
        # Only "true" string makes it true
        not_translated: params["not_translated"] == "true"
    }
  end

  # Builds params for quering the Data Access implementaiton from the liveview `options` format
  @spec build_data_access_params(options()) :: DataAccess.list_params()
  defp build_data_access_params(opts) when is_map(opts) do
    sort = {opts.sort_by, opts.sort_order}
    pagination = %{type: :page, page: opts.page, size: opts.page_size}

    # Build base filters from required fields
    filters =
      %{}
      |> add_filter(:domain, opts.domain)
      |> add_filter(:msgctxt, opts.context)
      |> add_filter(:locale, opts.locale)
      |> add_translation_filter(opts.not_translated)
      |> add_search_filter(:search_text, opts.search)

    %{filters: filters, sort: sort, pagination: pagination}
  end

  defp add_filter(filters, _name, nil), do: filters
  defp add_filter(filters, name, value), do: Map.put(filters, name, value)
  # Helper functions to add specific filters conditionally
  defp add_translation_filter(filters, true), do: Map.put(filters, :msgstr, nil)
  defp add_translation_filter(filters, _), do: filters

  defp add_search_filter(filters, filter_name, search) when is_binary(search) and search != "" do
    Map.put(filters, filter_name, String.trim(search))
  end

  defp add_search_filter(filters, _, _), do: filters

  @spec build_query_params(options()) :: map()
  defp build_query_params(options) do
    params =
      Map.take(options, [
        :page,
        :page_size,
        :sort_by,
        :sort_order,
        :domain,
        :context,
        :search,
        :not_translated
      ])

    # Don't include default in the result parameter set
    params
    |> Map.reject(fn
      {:sort_by, @default_sort_by} -> true
      {:sort_order, @default_sort_order} -> true
      {:page_size, @default_page_size} -> true
      {:page, 1} -> true
      # Reject empty search string
      {:search, ""} -> true
      # Reject nil search string
      {:search, nil} -> true
      # Reject if not_translated was false (became nil)
      {:not_translated, nil} -> true
      {:not_translated, false} -> true
      # Reject any other nil values
      {_k, v} -> is_nil(v)
    end)
  end

  # --- URL Building ---
  @spec build_translation_url(socket :: Socket.t(), options :: map()) :: String.t()
  defp build_translation_url(socket, options) do
    query_string =
      options
      |> build_query_params()
      |> URI.encode_query()

    base_path = dashboard_path(socket, "/locales/#{options.locale}/translations")
    if query_string == "", do: base_path, else: "#{base_path}?#{query_string}"
  end

  # ----------------------------------------------------------------------------
  # Display Helpers (used in HEEx template)
  # These functions are part of the LiveView's public API for its template
  # ----------------------------------------------------------------------------
  defp print_msgid(msgid) when is_binary(msgid) do
    if String.length(msgid) > 30, do: String.slice(msgid, 0..25) <> "[...]", else: msgid
  end

  defp print_msgid(msgid), do: msgid

  defp print_original_translation(%Singular{} = singular) do
    print_translation(singular.msgstr_origin)
  end

  defp print_original_translation(%Plurals{} = plurals) do
    display_rows =
      plurals.plural_translations
      |> Enum.map(fn %Plural{msgstr_origin: msgstr, plural_index: plural_index} ->
        {plural_index, msgstr}
      end)
      |> Enum.sort()

    assigns = %{rows: display_rows}

    ~H"""
    <%= for {plural_index, msgstr} <- @rows do %>
      <div class={["text-green-700 dark:text-green-500", is_nil(msgstr) && "text-red-700 dark:text-red-500"]}>
      Plural form <%= plural_index %>: <%= print_translation(msgstr) %>
      </div>
    <% end %>
    """
  end

  defp print_kanta_translation(%Singular{} = singular) do
    print_translation(singular.msgstr)
  end

  defp print_kanta_translation(%Plurals{} = plurals) do
    display_rows =
      plurals.plural_translations
      |> Enum.map(fn %Plural{msgstr: msgstr, plural_index: plural_index} ->
        {plural_index, msgstr}
      end)
      |> Enum.sort()

    assigns = %{rows: display_rows}

    ~H"""
    <%= for {plural_index, msgstr} <- @rows do %>
      <div class={["text-green-700 dark:text-green-500", is_nil(msgstr) && "text-red-700 dark:text-red-500"]}>
      Plural form <%= plural_index %>: <%= print_translation(msgstr) %>
      </div>
    <% end %>
    """
  end

  defp translated?(%Plurals{} = _plurals) do
    true
  end

  defp translated?(%Singular{} = _singular) do
    true
  end

  # #       ~H"""
  #   <div>
  #     <%= for plural_translation <- Enum.sort_by(@translations, & &1[:index], :asc) do %>
  #       <div class={"#{if plural_translation[:text] != "Missing", do: "text-green-700 dark:text-green-500", else: "text-red-700 dark:text-red-500"}"}>
  #         Plural form <%= plural_translation[:index] %>: <%= plural_translation[:text] %>
  #       </div>
  #     <% end %>
  #   </div>
  # """

  defp print_translation(""), do: "Missing"
  defp print_translation(nil), do: "Missing"
  defp print_translation(msgstr), do: msgstr

  defp print_domain(nil), do: "None"
  defp print_domain(domain_name), do: domain_name

  defp print_context(nil), do: "Default"
  defp print_context(""), do: "Default"
  defp print_context(context_name), do: context_name

  defp lookup_domain_color(nil, _domain_colors), do: Colors.default_color()
  defp lookup_domain_color("", domain_colors), do: lookup_domain_color(nil, domain_colors)

  defp lookup_domain_color(domain_name, domain_colors) do
    Map.get(domain_colors, domain_name, Colors.default_color()) || Colors.default_color()
  end

  defp lookup_context_color(nil, _context_colors), do: Colors.default_color()
  defp lookup_context_color("", context_colors), do: lookup_context_color(nil, context_colors)

  defp lookup_context_color(context_name, context_colors) do
    Map.get(context_colors, context_name, Colors.default_color()) || Colors.default_color()
  end

  defp print_translation_type(%Plurals{}), do: "Plural"
  defp print_translation_type(_message), do: "Singular"

  # ----------------------------------------------------------------------------
  # Table Header Helpers (used in HEEx template)
  # ----------------------------------------------------------------------------

  defp header_label(
         description,
         # The atom representing the field for this header
         target_field,
         %{sort_by: current_sort_by, sort_order: current_sort_order} = options,
         socket
       ) do
    # Determine the sort parameters that the link should apply when clicked
    {link_sort_by, link_sort_order} =
      generate_sort_params(current_sort_by, current_sort_order, target_field)

    # Determine the visual indicator to display based on the current sort state
    indicator_symbol =
      current_sort_indicator_for_display(current_sort_by, current_sort_order, target_field)

    # Prepare the options that will be used to build the link's URL
    updated_options_for_link = %{
      options
      | sort_by: link_sort_by,
        sort_order: link_sort_order,
        page: 1
    }

    assigns = %{
      description: description,
      sort_indicator: indicator_symbol,
      path: build_translation_url(socket, updated_options_for_link)
    }

    ~H"""
    <.link patch={@path} class="flex items-center space-x-1 hover:text-primary">
      <span><%= @description %></span>
      <%= if @sort_indicator != "" do %>
        <span class="text-xs"><%= @sort_indicator %></span>
      <% end %>
    </.link>
    """
  end

  # Calculates the {field, order} the table should be sorted by if the target_field header is clicked.
  # If the target_field is already the sorted column, its order is toggled.
  # If it's a new column, it defaults to :desc (matching original behavior).
  defp generate_sort_params(current_sort_by, current_sort_order, target_field) do
    if current_sort_by == target_field do
      next_sort_order =
        case current_sort_order do
          :asc -> :desc
          :desc -> :asc
        end

      {target_field, next_sort_order}
    else
      # Default to :desc when a new column header is clicked
      {target_field, :desc}
    end
  end

  # Determines the visual sort indicator (▲/▼) for a column based on the current sort state.
  # Returns an empty string if the column is not currently sorted.
  defp current_sort_indicator_for_display(current_sort_by, current_sort_order, target_field) do
    if current_sort_by == target_field do
      sort_indicator_symbol(current_sort_order)
    else
      ""
    end
  end

  # Returns the visual symbol for a given sort order.
  defp sort_indicator_symbol(:asc), do: "▲"
  defp sort_indicator_symbol(:desc), do: "▼"
  # Fallback for any other value
  defp sort_indicator_symbol(_), do: ""
end
