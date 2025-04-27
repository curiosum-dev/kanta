defmodule Kanta.DataAccess.Model.Metadata.Context do
  @typedoc """
  Type that represents a translation context entity.
  """
  @type t :: %{
          id: any(),
          name: String.t(),
          description: String.t(),
          color: String.t()
        }
end
