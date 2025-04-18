defmodule Kanta.DataAccess.Model.Metadata.Context do
  @typedoc """
  Type that represents a translation context entity.
  """
  @type t :: %{
          # Optional
          id: any(),
          name: String.t(),
          description: String.t(),
          color: String.t()
          # Add timestamps if needed
        }
end
