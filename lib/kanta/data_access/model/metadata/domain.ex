defmodule Kanta.DataAccess.Model.Metadata.Domain do
  @moduledoc """
  A domain represents a category or field of expertise for translations.
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
    description: String.t() | nil,
    color: String.t() | nil
  }
end
