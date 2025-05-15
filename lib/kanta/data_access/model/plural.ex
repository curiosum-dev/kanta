defmodule Kanta.DataAccess.Model.Plural do
  @moduledoc """
  Defines the plural translation record struct used within Kanta.
  This is independent of the persistence layer.
  """

  @typedoc """
  Struct representing a plural translation record
  """

  defstruct [
    :id,
    :locale,
    :domain,
    :msgctxt,
    :msgid,
    :msgid_plural,
    :plural_index,
    :msgstr,
    :msgstr_origin
    # Add timestamps if needed
  ]

  @type t :: %__MODULE__{
          id: any(),
          locale: String.t(),
          domain: String.t(),
          msgctxt: String.t() | nil,
          msgid: String.t(),
          msgid_plural: String.t(),
          plural_index: non_neg_integer(),
          msgstr: String.t() | nil,
          msgstr_origin: String.t()
        }
end
