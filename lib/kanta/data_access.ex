defmodule Kanta.DataAccess do
  @moduledoc """
  Behaviour defining the explicit contract for Kanta's data access layer.

  Specifies functions for CRUD operations for each specific Kanta entity type
  (Singular/Plural Translations, Domain/Context Metadata).

  Implementations should provide functions matching these signatures.
  The return types reference the plain data structures defined in `Kanta.Translation`.

  ## List Parameters

  Many functions in this module accept a `list_params` parameter for filtering, sorting, and pagination.
  Here's how to structure this parameter:

  ### Structure

  The `list_params` parameter is a map with the following optional keys:

  ```elixir
  %{
    filters: list_filters(),      # Optional filtering criteria
    sort: list_sort(),            # Optional sorting specification
    pagination: list_pagination() # Optional pagination controls
  }
  ```

  You can provide any combination of these keys or an empty map (`%{}`) to retrieve all records without filtering, sorting, or pagination.

  ### Filters

  Filters allow you to narrow down the results based on specific criteria:

  ```elixir
  %{filters: %{field_name: value}}
  ```

  Examples:
  ```elixir
  # Filter translations by locale
  %{filters: %{locale: "en"}}

  # Filter by multiple criteria
  %{filters: %{domain: "website", locale: "es"}}
  ```

  ### Sorting

  Sorting defines the order of results based on a field:

  ```elixir
  %{sort: {field_name, direction}}
  ```

  Where:
  - `field_name` is an atom representing the field to sort by
  - `direction` is either `:asc` (ascending) or `:desc` (descending)

  Examples:
  ```elixir
  # Sort by key in ascending order
  %{sort: {:key, :asc}}

  # Sort by updated_at in descending order (newest first)
  %{sort: {:updated_at, :desc}}
  ```

  ### Pagination

  Kanta supports two pagination methods:

  #### Page-based Pagination

  ```elixir
  %{pagination: %{type: :page, page: page_number, size: page_size}}
  ```

  Where:
  - `page_number` is a positive integer representing the page to retrieve
  - `page_size` is a positive integer representing the number of items per page

  Example:
  ```elixir
  # Get the second page with 20 items per page
  %{pagination: %{type: :page, page: 2, size: 20}}
  ```

  #### Offset-based Pagination

  ```elixir
  %{pagination: %{type: :offset, offset: offset_value, limit: limit_value}}
  ```

  Where:
  - `offset_value` is a non-negative integer representing how many records to skip
  - `limit_value` is a positive integer representing the maximum number of records to return

  Example:
  ```elixir
  # Skip 40 records and get the next 20
  %{pagination: %{type: :offset, offset: 40, limit: 20}}
  ```

  ### Combined Examples

  ```elixir
  # Get the first page of English translations in the "website" domain,
  # sorted by key alphabetically
  %{
    filters: %{locale: "en", domain: "website"},
    sort: {:key, :asc},
    pagination: %{type: :page, page: 1, size: 25}
  }

  # Get 10 Spanish translations, newest first
  %{
    filters: %{locale: "es"},
    sort: {:updated_at, :desc},
    pagination: %{type: :offset, offset: 0, limit: 10}
  }
  ```

  The returned data includes both the filtered results and pagination metadata to help with navigation.
  """

  alias Kanta.DataAccess.PaginationMeta

  # Define resource types using modules rather than atoms
  @type resource_module ::
          :singular | :plural | :domain | :context | :application_source
  @type id :: any()
  @type implementation_opts :: keyword()

  @type list_filters :: %{atom() => any()} | %{}
  @type list_sort :: {atom(), :asc | :desc} | nil
  @type list_pagination ::
          %{type: :page, page: pos_integer(), size: pos_integer()}
          | %{type: :offset, offset: non_neg_integer(), limit: pos_integer()}
          | %{}
  @type list_params ::
          %{
            optional(:filters) => list_filters(),
            optional(:sort) => list_sort(),
            optional(:pagination) => list_pagination()
          }
          | %{}
  @type pagination_meta :: %PaginationMeta{
          page: pos_integer(),
          page_size: pos_integer(),
          total_pages: non_neg_integer(),
          total_entries: non_neg_integer()
        }

  @type resource_result(type) :: {:ok, type} | {:error, any()}
  @type list_result :: {:ok, {list(map()), pagination_meta()}} | {:error, any()}
  @type get_result :: {:ok, map() | nil} | {:error, any()}
  @type command_result :: {:ok, map()} | {:error, any()}
  @type delete_result :: {:ok, map()} | {:error, :not_found | any()}
  @type locale :: String.t()
  @type locales :: [String.t()]

  # Core generic callbacks using module names
  @callback init(opts :: keyword()) :: :ok

  @callback list_translations(
              params :: list_params(),
              opts :: implementation_opts()
            ) ::
              list_result()

  @callback list_resources(
              resource_module :: resource_module,
              params :: list_params(),
              opts :: implementation_opts()
            ) ::
              list_result()
  @callback get_resource(
              resource_module :: resource_module,
              id :: id(),
              opts :: implementation_opts()
            ) ::
              get_result()
  @callback create_resource(
              resource_module :: resource_module,
              attrs :: map(),
              opts :: implementation_opts()
            ) ::
              command_result()
  @callback update_resource(
              resource_module :: resource_module,
              id :: id(),
              attrs :: map(),
              opts :: implementation_opts()
            ) ::
              command_result()
  @callback delete_resource(
              resource_module :: resource_module,
              id :: id(),
              opts :: implementation_opts()
            ) ::
              delete_result()

  @callback count_resource(resource_module :: resource_module) :: integer()
  @callback locales() :: locales
  @callback locales_translation_progress(locales) :: %{locale => float()}

  @doc """
    Updates all the metadata based on the translation data.

    In particular updated: Context, Domain information.
  """
  @callback update_metadata() :: :ok | {:error, any()}

  defguard is_resource(resource_module)
           when resource_module in [:singular, :plural, :context, :domain, :application_source]
end
