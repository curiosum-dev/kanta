defmodule Kanta.Types do
  @moduledoc """
  Types used in Kanta
  """

  @typedoc "A string or integer identifier"
  @type id() :: String.t() | integer()

  @typedoc "A schema or Ecto.Association.NotLoaded"
  @type assoc_type(schema_type) ::
          schema_type
          | Ecto.Association.NotLoaded.t()
          | nil

  @typedoc "A schema field value of a given type or nil"
  @type field(field_type) :: field_type | nil
end
