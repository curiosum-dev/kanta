defmodule Kanta.DataAccess.Model.Plural do
  @typedoc """
  Struct representing a plural translation record
  """
  @type t :: %{
          id: any(),
          locale: String.t(),
          domain: String.t(),
          msgctxt: String.t() | nil,
          msgid: String.t(),
          msgid_plural: String.t(),
          plural_index: non_neg_integer(),
          msgstr: String.t() | nil,
          msgstr_origin: String.t()
          # Add timestamps if needed
        }
end
