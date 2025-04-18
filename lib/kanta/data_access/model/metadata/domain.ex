defmodule Kanta.DataAccess.Model.Metadata.Domain do
  @typedoc """
  A domain represents a category or field of expertise for translations.
  """
  @type t :: %{
          id: any(),
          name: String.t(),
          description: String.t() | nil,
          color: String.t() | nil
          # Add timestamps if needed
        }
end
