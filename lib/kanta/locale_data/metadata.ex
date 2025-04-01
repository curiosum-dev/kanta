defmodule Kanta.LocaleData.Metadata do
  @typedoc """
  Represents metadata associated with a locale.
  - `language_name`: The English name of the language (String).
  - `unicode_flag`: The Unicode flag emoji string (String), or `nil`.
  - `flag_colors`: A list of hex color strings for the flag (List(String)), or `nil`.
  """
  @type t :: %__MODULE__{
          language_name: String.t() | nil,
          unicode_flag: String.t() | nil,
          flag_colors: list(String.t()) | nil
        }

  defstruct language_name: nil,
            unicode_flag: nil,
            flag_colors: nil
end
