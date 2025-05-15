defmodule Kanta.DataAccess.Model.Metadata.ApplicationSource do
  @moduledoc """
  Represents a source of translations within the application.
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
