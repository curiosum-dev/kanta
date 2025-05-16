defmodule Kanta.DataAccess.Model.Plurals do
  @type t :: %__MODULE__{
          id: String.t(),
          locale: String.t(),
          domain: String.t(),
          msgctxt: String.t() | nil,
          msgid: String.t(),
          msgid_plural: String.t(),
          plural_translations: [Kanta.DataAccess.Model.Plural.t()]
        }

  defstruct [
    :id,
    :locale,
    :domain,
    :msgctxt,
    :msgid,
    :msgid_plural,
    :plural_translations
  ]
end
