defmodule Kanta.DataAccess.Model.Metadata.ApplicationSource do
  @type t :: %{
          id: any(),
          name: String.t(),
          description: String.t(),
          color: String.t()
        }
end
