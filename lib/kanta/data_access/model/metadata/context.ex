defmodule Kanta.DataAccess.Model.Metadata.Context do
  @moduledoc """
  Type that represents a translation context entity.
  """
  
  defstruct [
    :id,
    :name,
    :description,
    :color
  ]
  
  @type t :: %__MODULE__{
    id: any(),
    name: String.t(),
    description: String.t(),
    color: String.t()
  }
end
