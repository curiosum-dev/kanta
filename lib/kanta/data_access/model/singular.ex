defmodule Kanta.DataAccess.Model.Singular do
  @moduledoc """
  Defines the singular translation record struct used within Kanta.
  This is independent of the persistence layer.
  """

  @typedoc """
  Struct representing a singular translation record
  """

  defstruct [
    :id,
    :locale,
    :domain,
    :msgctxt,
    :msgid,
    :msgstr,
    :msgstr_origin
    # Add timestamps if they exist in your schema and you want them here
    # :inserted_at,
    # :updated_at
  ]

  @type t :: %__MODULE__{
          id: any(),
          locale: String.t(),
          domain: String.t(),
          msgctxt: String.t() | nil,
          msgid: String.t(),
          msgstr: String.t() | nil,
          msgstr_origin: String.t()
          # inserted_at: NaiveDateTime.t(),
          # updated_at: NaiveDateTime.t()
        }
end
