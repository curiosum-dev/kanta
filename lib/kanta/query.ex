defmodule Kanta.Query do
  @moduledoc """
    This module is a base for all queries modules in the app.

    Including it into given resource query module is as easy as:
    ```
    use Kanta.Query,
      module: Kanta.ResourceModuleGoesHere,
      binding: :resource_binding_goes_here
    ```
  """

  defmacro __using__(opts \\ []) do
    # credo:disable-for-next-line Credo.Check.Refactor.LongQuoteBlocks
    quote do
      import Ecto.Query

      alias Kanta.Repo

      # Returns the base for resource query with binding.
      #
      # ## Examples
      #
      # iex> base()
      # #Ecto.Query<from u0 in Kanta.Accounts.User, as: :user
      #
      @spec base :: Ecto.Query.t()
      def base do
        from(_ in unquote(opts[:module]), as: unquote(opts[:binding]))
      end

      def one(query \\ base(), opts \\ []) do
        Repo.get_repo().one(query, opts)
      end

      def paginate(query, page \\ 1, per_page \\ 15)
      def paginate(query, nil, nil), do: paginate(query, 1, 15)

      def paginate(query, page, per_page) do
        %{
          entries: entries,
          page_number: page_number,
          page_size: page_size,
          total_pages: total_pages,
          total_entries: total_entries
        } =
          Scrivener.paginate(
            query,
            %Scrivener.Config{
              caller: self(),
              module: Repo.get_repo(),
              page_number: page || 1,
              page_size: per_page || 15,
              options: []
            }
          )

        %{
          entries: entries,
          metadata: %{
            page_number: page_number,
            page_size: page_size,
            total_pages: total_pages,
            total_entries: total_entries
          }
        }
      end

      @doc """
      Returns unique resources.

      ## Examples

          iex> Kanta.Accounts.UserQueries.unique()
          #Ecto.Query<from u0 in Kanta.Accounts.User, as: :user, distinct: true>
      """
      def unique(query \\ base(), column \\ true)
      def unique(query, true), do: distinct(query, true)

      def unique(query, column) when is_atom(column) do
        distinct(
          query,
          [{unquote(opts[:binding]), resource}],
          field(resource, ^column)
        )
      end

      @doc """
      Select specific one column from resource.

      ## Examples

          iex> Kanta.Accounts.UserQueries.select_column(:email)
          #Ecto.Query<from u0 in Kanta.Accounts.User, as: :user, select: u0.email>
      """
      @spec select_column(Ecto.Query.t(), atom()) :: Ecto.Query.t()
      def select_column(query \\ base(), column) do
        select(
          query,
          [{unquote(opts[:binding]), resource}],
          field(resource, ^column)
        )
      end

      @doc """
      Preloads resources for given resource.

      ## Examples

          iex> Kanta.Accounts.UserQueries.preload_resources(:articles)
          #Ecto.Query<from u0 in Kanta.Accounts.User, as: :user,
            preload: [[:articles]]>
      """
      @spec preload_resources(Ecto.Query.t(), keyword()) :: Ecto.Query.t()
      def preload_resources(query \\ base(), preloads) do
        preload(query, ^preloads)
      end

      @doc """
      Counts resources by specific column.

      ## Examples

          iex> Kanta.Accounts.UserQueries.count(:email)
          #Ecto.Query<from u0 in Kanta.Accounts.User, as: :user,
            select: count(u0.email)>
      """
      @spec count(Ecto.Query.t(), atom()) :: Ecto.Query.t()
      def count(query \\ base(), column) do
        select(
          query,
          [{unquote(opts[:binding]), resource}],
          field(resource, ^column) |> count()
        )
      end

      @doc """
      Filters given resource by specific criterias. Filters should be pass to the function as map `%{"field_name" => filter_value}`.
      It supports associations: `%{"association" => %{"field_name" => filter_value}}`
      and nested associations `%{"association" => %{"nested association" => %{"field_name" => filter_value}}}`

      ## Examples

          iex> Kanta.Accounts.UserQueries.filter_query(%{"email" => "a@a.com"})
          #Ecto.Query<from u0 in Kanta.Accounts.User, as: :user, where: u0.email == ^"a@a.com">
      """
      @spec filter_query(Ecto.Query.t(), map() | keyword() | nil) :: Ecto.Query.t()
      def filter_query(query \\ base(), filters)
      def filter_query(query, nil), do: query

      def filter_query(query, filters) when is_list(filters) do
        filters
        |> Enum.into(%{})
        |> then(&filter_query(query, &1))
      end

      def filter_query(query, filters) do
        Enum.reduce(filters, query, fn
          {association, fields}, q when is_map(fields) ->
            association_atom = maybe_convert_to_atom(association)

            query = from([..., s] in q, join: a in assoc(s, ^association_atom))

            Enum.reduce(fields, query, fn
              {assoc, values}, current_query when is_map(values) ->
                filter_query(current_query, %{assoc => values})

              {field_name, value}, current_query ->
                get_field_name(value, current_query, field_name)
            end)

          {field_name, value}, q ->
            try do
              field_name = maybe_convert_to_atom(field_name)

              get_query_operation(q, value, field_name)
            rescue
              _e ->
                q
            end
        end)
      end

      defp get_query_operation(query, value, field_name) do
        query
        |> maybe_inclusion(value, field_name)
        |> maybe_greater_than(value, field_name)
        |> maybe_greater_or_equal_than(value, field_name)
        |> maybe_lower_than(value, field_name)
        |> maybe_lower_or_equal_than(value, field_name)
        |> maybe_equality(value, field_name)
      end

      defp maybe_inclusion(q, value, field_name) do
        if is_list(value) do
          if Enum.all?(value, &String.match?(&1, ~r/(>|>=|<|<=).*/)) do
            combine_inclusion_filters(q, value, field_name)
          else
            from(s in q, where: field(s, ^field_name) in ^value)
          end
        else
          q
        end
      end

      defp combine_inclusion_filters(q, value, field_name) do
        Enum.reduce(value, q, fn value_element, query ->
          get_query_operation(query, value_element, field_name)
        end)
      end

      defp maybe_greater_than(q, value, field_name) do
        if is_binary(value) && String.starts_with?(value, ">") do
          value = String.trim_leading(value, ">")
          from(s in q, where: field(s, ^field_name) > ^value)
        else
          q
        end
      end

      defp maybe_greater_or_equal_than(q, value, field_name) do
        if is_binary(value) && String.starts_with?(value, ">=") do
          value = String.trim_leading(value, ">=")
          from(s in q, where: field(s, ^field_name) >= ^value)
        else
          q
        end
      end

      defp maybe_lower_than(q, value, field_name) do
        if is_binary(value) && String.starts_with?(value, "<") do
          value = String.trim_leading(value, "<")
          from(s in q, where: field(s, ^field_name) < ^value)
        else
          q
        end
      end

      defp maybe_lower_or_equal_than(q, value, field_name) do
        if is_binary(value) && String.starts_with?(value, "<=") do
          value = String.trim_leading(value, "<=")
          from(s in q, where: field(s, ^field_name) <= ^value)
        else
          q
        end
      end

      defp maybe_equality(q, value, field_name) do
        if (is_binary(value) && String.match?(value, ~r/(>|>=|<|<=).*/)) || is_list(value) do
          q
        else
          from(s in q, where: field(s, ^field_name) == ^value)
        end
      end

      defp get_field_name(value, current_query, field_name) when is_binary(field_name) do
        get_field_name(value, current_query, String.to_existing_atom(field_name))
      end

      defp get_field_name(value, current_query, field_name) do
        if is_list(value) do
          field_name =
            from([..., r] in current_query,
              where: field(r, ^field_name) in ^value
            )
        else
          field_name =
            from([..., r] in current_query,
              where: field(r, ^field_name) == ^value
            )
        end
      end

      defp maybe_convert_to_atom(field_name) when is_binary(field_name) do
        String.to_existing_atom(field_name)
      end

      defp maybe_convert_to_atom(field_name) when is_atom(field_name) do
        field_name
      end

      @doc """
      Search for rows by given text.

      ## Examples

          iex> Kanta.Accounts.UserQueries.search_query("some text")
          #Ecto.Query<from u0 in Kanta.Accounts.User, where: fragment("to_tsvector(?::text) @@ plainto_tsquery(?)", u0, ^"some text")>
      """
      @spec search_query(Ecto.Query.t(), any()) :: Ecto.Query.t()
      def search_query(query \\ base(), search)
      def search_query(query, nil), do: query
      def search_query(query, ""), do: query

      def search_query(query, search) do
        from(s in unquote(opts[:module]),
          where:
            fragment(
              "searchable @@ websearch_to_tsquery(?)",
              ^search
            ),
          order_by: {
            :desc,
            fragment(
              "ts_rank_cd(searchable, websearch_to_tsquery(?), 4)",
              ^search
            )
          }
        )
      end

      @spec order_query(Ecto.Query.t(), keyword()) :: Ecto.Query.t()
      def order_query(query \\ base(), order) do
        order_by(query, [{unquote(opts[:binding]), resource}], ^order)
      end

      @spec undeleted_query(Ecto.Query.t()) :: Ecto.Query.t()
      def undeleted_query(query \\ base()) do
        from(q in unquote(opts[:module]),
          where: is_nil(q.deleted_at),
          where: is_nil(q.deleted_by)
        )
      end
    end
  end
end
