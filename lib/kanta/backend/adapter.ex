defmodule Kanta.Backend.Adapter do
  @moduledoc """
  Defines the behavior for Kanta adapters used in translation lookups.

  Adapters implementing this behavior are responsible for handling
  translation lookups for both singular and plural forms.
  """

  @doc """
  Looks up a singular translation in the specified locale and domain.

  ## Parameters

  - `locale` - The locale code (e.g., "en", "fr")
  - `domain` - The translation domain name
  - `msgctxt` - Optional message context, or nil if no context
  - `msgid` - The message identifier to translate
  - `bindings` - Map or keyword list of bindings for interpolation

  ## Returns

  - `{:ok, translated_string}` - When the translation is found
  - `{:error, :not_found}` - When the translation is not found
  """
  @callback lgettext(
              locale :: String.t(),
              domain :: String.t(),
              msgctxt :: String.t() | nil,
              msgid :: String.t(),
              bindings :: Keyword.t() | map()
            ) :: {:ok, String.t()} | {:error, :not_found}

  @doc """
  Looks up a plural translation in the specified locale and domain.

  ## Parameters

  - `locale` - The locale code (e.g., "en", "fr")
  - `domain` - The translation domain name
  - `msgctxt` - Optional message context, or nil if no context
  - `msgid` - The singular message identifier
  - `msgid_plural` - The plural message identifier
  - `n` - The count to determine which plural form to use
  - `bindings` - Map or keyword list of bindings for interpolation

  ## Returns

  - `{:ok, translated_string}` - When the translation is found
  - `{:error, :not_found}` - When the translation is not found
  """
  @callback lngettext(
              locale :: String.t(),
              domain :: String.t(),
              msgctxt :: String.t() | nil,
              msgid :: String.t(),
              msgid_plural :: String.t(),
              n :: non_neg_integer(),
              bindings :: Keyword.t() | map()
            ) :: {:ok, String.t()} | {:error, :not_found}
end
