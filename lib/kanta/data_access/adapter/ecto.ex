defmodule Kanta.DataAccess.Adapter.Ecto do
  @moduledoc """
  Provides an Ecto-based implementation helper for the explicit `Kanta.DataAccess` behaviour.
  """

  import Ecto.Query, warn: false

  alias Flop.Meta
  alias Kanta.DataAccess.PaginationMeta
  alias Kanta.DataAccess.Adapter.Ecto.Singular, as: SingularSchema
  alias Kanta.DataAccess.Adapter.Ecto.Plural, as: PluralSchema
  alias Kanta.DataAccess.Adapter.Ecto.Metadata.Domain, as: DomainSchema
  alias Kanta.DataAccess.Adapter.Ecto.Metadata.Context, as: ContextSchema
  alias Kanta.DataAccess.Adapter.Ecto.Converter

  import Kanta.DataAccess, only: [is_resource: 1]

  # --- __using__ Macro (No changes needed here) ---
  @doc false
  defmacro __using__(opts) do
    repo_module = Keyword.get(opts, :repo)
    unless repo_module, do: raise(ArgumentError, "The :repo option is required.")

    quote do
      @behaviour Kanta.DataAccess
      alias Kanta.DataAccess.Adapter.Ecto, as: EctoAdapter
      import Kanta.DataAccess, only: [is_resource: 1]
      @repo unquote(repo_module)

      @impl Kanta.DataAccess
      def init(_opts) do
        EctoAdapter.do_init(@repo)
      end

      @impl Kanta.DataAccess
      def list_translations(params, opts \\ []),
        do: EctoAdapter.do_list_translations(@repo, params, opts)

      @impl Kanta.DataAccess
      def list_resources(resource_module, params, opts \\ [])
          when is_resource(resource_module),
          do: EctoAdapter.do_list(@repo, resource_module, params, opts)

      @impl Kanta.DataAccess
      def get_resource(resource_module, id, opts)
          when is_resource(resource_module),
          do: EctoAdapter.do_get(@repo, resource_module, id, opts)

      @impl Kanta.DataAccess
      def create_resource(resource_module, attrs, opts \\ [])
          when is_resource(resource_module),
          do: EctoAdapter.do_create(@repo, resource_module, attrs, opts)

      @impl Kanta.DataAccess
      def update_resource(resource_module, id, attrs, opts)
          when is_resource(resource_module),
          do: EctoAdapter.do_update(@repo, resource_module, id, attrs, opts)

      @impl Kanta.DataAccess
      def delete_resource(resource_module, id, opts),
        do: EctoAdapter.do_delete(@repo, resource_module, id, opts)

      @impl Kanta.DataAccess
      def update_metadata(), do: EctoAdapter.do_update_metadata(@repo)

      @impl Kanta.DataAccess
      def count_resource(resource_module),
        do: EctoAdapter.do_count_resource(@repo, resource_module)

      @impl Kanta.DataAccess
      def locales(), do: EctoAdapter.do_locales(@repo)

      @doc """
      Calculates the translation progress percentage for each locale.

      This function takes a list of locales and returns a map where each key is a locale
      and each value is the ratio of translated items to total items (as a float between 0 and 1).

      ## Example

          iex> DataAccess.locales_translation_progress(["en", "fr", "es"])
          %{"en" => 0.95, "fr" => 0.84, "es" => 0.67}
      """
      @impl Kanta.DataAccess
      def locales_translation_progress(locales),
        do: EctoAdapter.do_locales_translation_progress(@repo, locales)
    end
  end

  # --- Actual Implementation Logic (do_*) ---

  def do_init(repo) do
    result = Kanta.MigrationVersionChecker.check_version(repo)

    case result do
      true -> :ok
      false -> {:error, :migrations_not_run}
    end
  end

  @doc false
  def do_list_translations(repo, params, _opts) do
    import Ecto.Query

    flop = translate_to_flop_params(params) |> Flop.validate!()
    search_text = params[:search_text]

    # Build queries with proper filtering
    union_sub = build_translation_queries(search_text)

    # Combine the queries

    # Run the query with pagination
    {:ok, {results, flop_meta}} = Flop.validate_and_run(union_sub, flop, repo: repo)
    # Fetch full records for the results
    {singulars, plurals} = fetch_translation_records(repo, results)
    # Convert the results to the proper format
    results = convert_translation_results(results, singulars, plurals)

    # Return with pagination metadata
    meta = flop_meta_to_pagination_meta(flop_meta)
    {:ok, {results, meta}}
  end

  # Helper functions for do_list_translations

  defp build_translation_queries(search_text) do
    search_str = "%#{search_text}%"
    empty_search = is_nil(search_text) || search_text == ""

    singular_sub =
      from s in SingularSchema,
        select: %{
          type: "singular",
          id: s.id,
          msgid: s.msgid,
          domain: s.domain,
          msgctxt: s.msgctxt,
          locale: s.locale,
          plural_id: ""
        }

    singular_sub =
      if empty_search,
        do: singular_sub,
        else: singular_sub |> where([t], like(t.msgid, ^search_str))

    plural_sub =
      from p in PluralSchema,
        distinct: true,
        select: %{
          type: "plural",
          id: -1,
          msgid: p.msgid,
          domain: p.domain,
          msgctxt: p.msgctxt,
          locale: p.locale,
          plural_id: p.plural_id
        }

    # For plurals we search in both msgid and msgid plural
    plural_sub =
      if empty_search,
        do: plural_sub,
        else:
          plural_sub
          |> where([t], like(t.msgid, ^search_str) or like(t.msgid_plural, ^search_str))

    _union_sub = union(singular_sub, ^plural_sub) |> subquery()
  end

  defp fetch_translation_records(repo, results) do
    singular_ids =
      results
      |> Enum.filter(&(&1.type == "singular"))
      |> Enum.map(& &1.id)

    plural_ids =
      results
      |> Enum.filter(&(&1.type == "plural"))
      |> Enum.map(& &1.plural_id)
      |> Enum.uniq()

    singulars = from(s in SingularSchema, where: s.id in ^singular_ids) |> repo.all()
    plurals = from(p in PluralSchema, where: p.plural_id in ^plural_ids) |> repo.all()

    {singulars, plurals}
  end

  defp convert_translation_results(results, singulars, plurals) do
    Enum.map(results, fn
      %{type: "singular", id: id} ->
        result = Enum.find(singulars, fn %{id: result_id} -> result_id == id end)
        Converter.to_singular(result)

      %{type: "plural", plural_id: plural_group_id} ->
        plural_translations =
          for plural = %PluralSchema{plural_id: ^plural_group_id} <- plurals, do: plural

        Converter.to_plurals(plural_translations)
    end)
  end

  @doc false
  def do_list(repo, model, params, _opts) when is_resource(model) do
    schema = model_to_schema(model)
    flop_params = translate_to_flop_params(params)

    with {:ok, {results, flop_meta}} <-
           Flop.validate_and_run(schema, flop_params, repo: repo) do
      converted_results =
        case model do
          :singular -> Converter.to_singular(results)
          :plural -> Converter.to_plural(results)
          _ -> results
        end

      {:ok, {converted_results, flop_meta_to_pagination_meta(flop_meta)}}
    else
      # Propagate Flop/Repo errors
      {:error, error} ->
        {:error, error}
        # Catch potential other returns
    end
  end

  @doc false
  def do_get(repo, model, id, opts) when is_resource(model) do
    schema = model_to_schema(model)
    query = from(s in schema, where: s.id == ^id)
    query = maybe_preload(query, opts[:preload])

    try do
      case repo.one(query) do
        nil ->
          {:ok, nil}

        struct ->
          converted =
            case model do
              :singular -> Converter.to_singular(struct)
              :plural -> Converter.to_plural(struct)
              _ -> struct
            end

          {:ok, converted}
      end
    rescue
      # Catch any runtime error during the Repo operation
      e -> {:error, e}
    end
  end

  @doc false
  def do_create(repo, :singular, attrs, _opts) do
    case apply_changeset(SingularSchema, :create, %{}, attrs) do
      {:ok, %Ecto.Changeset{valid?: true} = changeset} ->
        case repo.insert(changeset,
               on_conflict: {:replace, [SingularSchema.msgstr_origin()]},
               conflict_target: SingularSchema.unique_fields()
             ) do
          {:ok, struct} -> {:ok, Converter.to_singular(struct)}
          error -> error
        end

      {:ok, %Ecto.Changeset{valid?: false} = changeset} ->
        {:error, changeset}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def do_create(repo, :plural, attrs, _opts) do
    case apply_changeset(PluralSchema, :create, %{}, attrs) do
      {:ok, %Ecto.Changeset{valid?: true} = changeset} ->
        case repo.insert(changeset,
               on_conflict: {:replace, [PluralSchema.msgstr_origin()]},
               conflict_target: PluralSchema.unique_fields()
             ) do
          {:ok, struct} -> {:ok, Converter.to_plural(struct)}
          error -> error
        end

      {:ok, %Ecto.Changeset{valid?: false} = changeset} ->
        {:error, changeset}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def do_create(repo, model, attrs, _opts) when is_resource(model) do
    schema = model_to_schema(model)

    case apply_changeset(schema, :create, %{}, attrs) do
      {:ok, %Ecto.Changeset{valid?: true} = changeset} ->
        case repo.insert(changeset) do
          {:ok, struct} ->
            converted =
              case model do
                :singular -> Converter.to_singular(struct)
                :plural -> Converter.to_plural(struct)
                _ -> struct
              end

            {:ok, converted}

          error ->
            error
        end

      {:ok, %Ecto.Changeset{valid?: false} = changeset} ->
        {:error, changeset}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc false
  def do_update(repo, model, id, attrs, _opts) when is_resource(model) do
    schema = model_to_schema(model)

    case repo.get(schema, id) do
      nil ->
        {:error, :not_found}

      struct ->
        case apply_changeset(schema, :update, struct, attrs) do
          {:ok, %Ecto.Changeset{valid?: true} = changeset} ->
            case repo.update(changeset) do
              {:ok, updated_struct} ->
                converted =
                  case model do
                    :singular -> Converter.to_singular(updated_struct)
                    :plural -> Converter.to_plural(updated_struct)
                    _ -> updated_struct
                  end

                {:ok, converted}

              error ->
                error
            end

          {:ok, %Ecto.Changeset{valid?: false} = changeset} ->
            {:error, changeset}

          {:error, reason} ->
            {:error, reason}
        end
    end
  end

  @doc false
  def do_delete(repo, model, id, _opts) when is_resource(model) do
    schema = model_to_schema(model)

    case repo.get(schema, id) do
      nil -> {:error, :not_found}
      struct -> repo.delete(struct)
    end
  end

  # Updates the metadata based on the content of the data
  def do_update_metadata(repo) do
    # Update domains
    update_schema_metadata(repo, DomainSchema, :domain)

    # Update contexts
    update_schema_metadata(repo, ContextSchema, :msgctxt)
  end

  @doc false
  def do_locales(repo) do
    singular_query =
      from s in SingularSchema,
        select: s.locale

    plural_query =
      from p in PluralSchema,
        select: p.locale

    query = union(singular_query, ^plural_query)

    repo.all(query)
  end

  @doc false
  def do_count_resource(repo, resource_module) do
    module = model_to_schema(resource_module)

    query =
      from resource in module,
        select: count()

    repo.one(query)
  end

  @doc false
  def do_locales_translation_progress(repo, _locales) do
    import Kanta.DataAccess.Adapter.Ecto.CustomFunctions

    singular_query =
      from s in SingularSchema,
        group_by: s.locale,
        select: %{
          locale: s.locale,
          count_translated: count_case(is_nil(s.msgstr), [[when: true, then: nil], [else: 1]]),
          count_total: count(s.id)
        }

    plural_query =
      from p in PluralSchema,
        group_by: p.locale,
        select: %{
          locale: p.locale,
          count_translated: count_case(is_nil(p.msgstr), [[when: true, then: nil], [else: 1]]),
          count_total: count(p.id)
        }

    union_query = union(singular_query, ^plural_query)

    query =
      from locale_progress in subquery(union_query),
        group_by: locale_progress.locale,
        select: {
          locale_progress.locale,
          sum(locale_progress.count_translated) / sum(locale_progress.count_total)
        }

    repo.all(query)
    |> Map.new()
  end

  ######## --- PRIVATE HELPERS  --- #######

  defp apply_changeset(schema, action, struct_or_map, attrs) do
    struct = if is_struct(struct_or_map), do: struct_or_map, else: struct!(schema, struct_or_map)
    func_name = specific_changeset_func(schema, action) || :changeset

    if function_exported?(schema, func_name, 2) do
      {:ok, apply(schema, func_name, [struct, attrs])}
    else
      {:error, {:changeset_function_not_found, schema, func_name}}
    end
  end

  # Corrected flop_meta_to_pagination_meta to use :current_page
  defp flop_meta_to_pagination_meta(%Meta{} = flop_meta) do
    %PaginationMeta{
      # Correct field for page number
      page: flop_meta.current_page,
      page_size: flop_meta.page_size,
      total_pages: flop_meta.total_pages || 0,
      total_entries: flop_meta.total_count || 0
    }
  end

  defp maybe_preload(query, nil), do: query

  defp maybe_preload(query, preloads) when is_list(preloads),
    do: Ecto.Query.preload(query, ^preloads)

  defp maybe_preload(query, preload), do: Ecto.Query.preload(query, ^preload)

  defp model_to_schema(resource_module) do
    case resource_module do
      :singular -> SingularSchema
      :plural -> PluralSchema
      :domain -> DomainSchema
      :context -> ContextSchema
    end
  end

  defp specific_changeset_func(schema, :create),
    do: if(function_exported?(schema, :create_changeset, 2), do: :create_changeset, else: nil)

  defp specific_changeset_func(schema, :update),
    do: if(function_exported?(schema, :update_changeset, 2), do: :update_changeset, else: nil)

  defp translate_to_flop_params(params) do
    flop_filters =
      case Map.get(params, :filters) do
        nil ->
          []

        filters_map when is_map(filters_map) ->
          Enum.map(filters_map, fn {field, value} ->
            %{field: field, op: :==, value: value}
          end)
      end

    flop_sorting =
      case Map.get(params, :sort) do
        {field, direction} when is_atom(field) and direction in [:asc, :desc] ->
          %{order_by: [field], order_directions: [direction]}

        _ ->
          %{}
      end

    flop_pagination =
      case Map.get(params, :pagination) do
        %{type: :page, page: p, size: s} -> %{page: p, page_size: s}
        %{type: :offset, offset: o, limit: l} -> %{offset: o, limit: l}
        _ -> %{}
      end

    flop_sorting
    |> Map.merge(flop_pagination)
    |> Map.put(:filters, flop_filters)
  end

  # Extracts column from the translations table to inserts into the metadata tables.
  defp update_schema_metadata(repo, target_schema, field_name) do
    singular_query =
      from s in SingularSchema,
        select: %{
          name: field(s, ^field_name),
          inserted_at: s.inserted_at,
          updated_at: s.updated_at
        }

    plural_query =
      from p in PluralSchema,
        select: %{
          name: field(p, ^field_name),
          inserted_at: p.inserted_at,
          updated_at: p.updated_at
        }

    all_query = union(singular_query, ^plural_query)

    repo.insert_all(target_schema, all_query,
      on_conflict: :nothing,
      conflict_target: [:name]
    )
  end
end
