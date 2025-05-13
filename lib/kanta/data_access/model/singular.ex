# kanta/lib/kanta/translation.ex
defmodule Kanta.DataAccess.Model.Singular do
  @moduledoc """
  Defines the core data types (structs) used within Kanta.
  These are independent of the persistence layer.
  """

  @typedoc """
  Struct representing a singular translation record
  """
  @type t :: %{
          id: any(),
          locale: String.t(),
          domain: String.t(),
          msgctxt: String.t() | nil,
          msgid: String.t(),
          msgstr: String.t() | nil,
          msgstr_origin: String.t(),
          type: :singular
          # Add timestamps if they exist in your schema and you want them here
          # inserted_at: NaiveDateTime.t(),
          # updated_at: NaiveDateTime.t()
        }
end
