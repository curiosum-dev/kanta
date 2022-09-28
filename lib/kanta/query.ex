# credo:disable-for-this-file Credo.Check.Refactor.LongQuoteBlocks
defmodule Kanta.Query do
  @moduledoc """
  This module is a base for all queries modules in the app.

  Including it into given resource query module is as easy as:
  ```
  use App.Query,
    module: App.ResourceModuleGoesHere,
    binding: :resource_binding_goes_here
  ```

  **Important!** You need to define two functions in you resource module:
  - `defp filter_by(_criteria, _query), do: raise ArgumentError, message: "wrong filter criteria"` since it's used by `filter/2`
  - `defp join_resource(_query, _), do: raise ArgumentError, message: "wrong join criteria"` since it's used by `with_join/2`
  """

  defmacro __using__(opts \\ []) do
    base =
      quote do
        import Ecto.Query

        @doc """
        Returns all resources without any conditions.

        ## Examples

            iex> App.Account.UserQueries.all()
            #Ecto.Query<from u0 in App.Account.User, as: :user>

        """
        @spec all :: Ecto.Query.t()
        def all, do: base()

        @doc """
        Returns unique resources.

        ## Examples

            iex> App.Account.UserQueries.unique()
            #Ecto.Query<from u0 in App.Account.User, as: :user, distinct: true>

        """
        @spec unique(Ecto.Query.t()) :: Ecto.Query.t()
        def unique(query \\ base()), do: distinct(query, true)

        @doc """
        Filters given resource by specific criterias.

        *Important!* The criterias have to be defined with filter_by/2 function. Example:
        ```
        defp filter_by({:id, id}, query) do
          query
          |> where([user: u], u.id == ^id)
        end
        ```

        First argument is a tuple of `{key_to_match, value_to_compare}` and second argument is a query.

        ## Examples

            iex> App.Account.UserQueries.filter(id: 1, email: "someone@example.com")
            #Ecto.Query<from u0 in App.Account.User, as: :user,
              where: u0.id == ^1,
              where: u0.email == ^"someone@example.com">

            # for dates comparison use tuple
            iex> App.Account.UserQueries.filter(inserted_at: {:<, Date.utc_today()})
            #Ecto.Query<from u0 in App.Account.User, as: :user,
              where: u0.inserted_at < ^~D[2022-07-28]>

        """
        @spec filter(Ecto.Query.t(), list({atom(), any()})) :: Ecto.Query.t()
        def filter(query \\ base(), criterias) do
          Enum.reduce(criterias, query, fn
            {key, {comparator, value}}, query -> filter_by(query, {key, comparator, value})
            {key, value}, query -> filter_by(query, {key, value})
          end)
        end

        @spec filter_by(Ecto.Query.t(), {atom(), any()}) :: no_return()
        @spec filter_by(Ecto.Query.t(), {atom(), any(), any()}) :: no_return()

        @doc """
        Select specific one column from resource.

        ## Examples

            iex> App.Account.UserQueries.select_column(:email)
            #Ecto.Query<from u0 in App.Account.User, as: :user, select: u0.email>

        """
        @spec select_resource(Ecto.Query.t()) :: Ecto.Query.t()
        def select_resource(query \\ base()) do
          select(query, [{unquote(opts[:binding]), resource}], resource)
        end

        @spec select_column(Ecto.Query.t(), atom()) :: Ecto.Query.t()
        def select_column(query \\ base(), column) do
          select(
            query,
            [{unquote(opts[:binding]), resource}],
            field(resource, ^column)
          )
        end

        @doc """
        Groups the query by specific resource field.

        ## Examples

            iex> App.Account.UserQueries.group_by_column(:email)
            #Ecto.Query<from u0 in App.Account.User, as: :user, group_by: [u0.email]>

        """
        @spec(group_by_column(Ecto.Query.t(), atom()) :: Ecto.Query.t(), atom())
        def group_by_column(query \\ base(), column) do
          group_by(
            query,
            [{unquote(opts[:binding]), resource}],
            field(resource, ^column)
          )
        end

        @doc """
        Preloads resources for given resource.

        ## Examples

            iex> App.Account.UserQueries.preload_resources(:articles)
            #Ecto.Query<from u0 in App.Account.User, as: :user,
              preload: [[:articles]]>

        """
        @spec preload_resources(Ecto.Query.t(), list(atom() | {atom(), atom()})) :: Ecto.Query.t()
        def preload_resources(query \\ base(), preloads) do
          preload(query, ^preloads)
        end

        @doc """
        Counts resources by specific column.

        ## Examples

            iex> App.Account.UserQueries.count(:email)
            #Ecto.Query<from u0 in App.Account.User, as: :user,
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
        Joins resource with another resource.

        *Important!* The joining has to be defined by join_resource/2 function. Example:
        ```
        defp join_resource(query, :articles) do
          query
          |> join(:left, [user: u], _ in assoc(u, :articles), as: :article)
        end
        ```

        First argument is a query and second argument is pattern-matched atom.

        ## Examples

            iex> App.Account.UserQueries.with_join(:articles)
            #Ecto.Query<from u0 in App.Account.User, as: :user,
              left_join: u1 in assoc(u0, :articles), as: :article>

        """
        @spec with_join(Ecto.Query.t(), atom()) :: Ecto.Query.t()
        def with_join(query \\ base(), resource_name) when is_atom(resource_name) do
          if has_named_binding?(query, resource_name) do
            query
          else
            join_resource(query, resource_name)
          end
        end

        @spec join_resource(Ecto.Query.t(), atom()) :: no_return()

        # Returns a query for paginating result set using limit and offset based
        # on page (1-indexed) and per_page settings.
        #
        # ## Examples
        #
        # iex> paginate(base(), 2, 5)
        # #Ecto.Query<from u0 in App.Account.User, as: :user>
        @spec paginate(Ecto.Query.t(), integer(), integer()) :: Ecto.Query.t()
        def paginate(query \\ base(), page, per_page) do
          query
          |> then(&if page, do: limit(&1, ^per_page), else: &1)
          |> then(&if page, do: offset(&1, (^page - 1) * ^per_page), else: &1)
        end

        @spec empty_query(Ecto.Query.t()) :: Ecto.Query.t()
        def empty_query(query), do: where(query, false)

        # Returns the base for resource query with binding.
        #
        # ## Examples
        #
        # iex> base()
        # #Ecto.Query<from u0 in App.Account.User, as: :user
        #
        @spec base :: Ecto.Query.t()
        defp base do
          from(_ in unquote(opts[:module]), as: unquote(opts[:binding]))
        end

        defp join_resource(_query, _), do: raise(ArgumentError, message: "wrong join criteria")
        defoverridable join_resource: 2
      end

    {_, _, module_path} = opts[:module]
    module = Module.concat(module_path)

    filter_by_functions =
      Enum.map(module.__schema__(:fields), fn field ->
        quote do
          # With the value equal to nil, it should use is_nil for comparison
          def filter_by(query, {unquote(field), nil}) do
            where(
              query,
              [{unquote(opts[:binding]), aliaz}],
              is_nil(aliaz.unquote(field))
            )
          end

          # With the value equal being a list, it should use in as a comparison
          def filter_by(query, {unquote(field), [_h | _t] = value}) do
            where(
              query,
              [{unquote(opts[:binding]), aliaz}],
              aliaz.unquote(field) in ^value
            )
          end

          def filter_by(query, {unquote(field), value}) do
            where(
              query,
              [{unquote(opts[:binding]), aliaz}],
              aliaz.unquote(field) == ^value
            )
          end

          def filter_by(query, {unquote(field), :<, value}) do
            where(
              query,
              [{unquote(opts[:binding]), aliaz}],
              aliaz.unquote(field) < ^value
            )
          end

          def filter_by(query, {unquote(field), :<=, value}) do
            where(
              query,
              [{unquote(opts[:binding]), aliaz}],
              aliaz.unquote(field) <= ^value
            )
          end

          def filter_by(query, {unquote(field), :>, value}) do
            where(
              query,
              [{unquote(opts[:binding]), aliaz}],
              aliaz.unquote(field) > ^value
            )
          end

          def filter_by(query, {unquote(field), :>=, value}) do
            where(
              query,
              [{unquote(opts[:binding]), aliaz}],
              aliaz.unquote(field) >= ^value
            )
          end
        end
      end)

    # base
    [base, filter_by_functions]
  end
end
