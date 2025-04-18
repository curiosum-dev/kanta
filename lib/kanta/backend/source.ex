defmodule Kanta.Backend.Source do
  @moduledoc """
  Defines the behaviour for Kanta backend sources.

  This module specifies the callbacks that must be implemented by any module that
  serves as a translation source for the Kanta internationalization system.
  """

  @doc """
  Looks up a translated message with singular form.

  ## Parameters

  * `backend` - The backend module implementing this behaviour
  * `locale` - The locale to use for the lookup
  * `domain` - The domain for the translation
  * `msgctxt` - The context of the message, or nil if none
  * `msgid` - The message ID to look up

  ## Returns

  * `{:ok, raw_msgstr}` - The translated message if found
  * `{:error, :not_found}` - If no translation is found
  """
  @callback lookup_lgettext(
              backend :: module(),
              locale :: binary,
              domain :: binary,
              msgctxt :: binary | nil,
              msgid :: binary
            ) ::
              {:ok, raw_msgstr :: binary} | {:error, :not_found}
  @doc """
  Looks up a translated message with plural forms.

  ## Parameters

  * `backend` - The backend module implementing this behaviour
  * `locale` - The locale to use for the lookup
  * `domain` - The domain for the translation
  * `msgctxt` - The context of the message, or nil if none
  * `msgid` - The singular message ID
  * `msgid_plural` - The plural message ID
  * `plural_index` - The index of the plural form to retrieve

  ## Returns

  * `{:ok, raw_msgstr}` - The translated message if found
  * `{:error, :not_found}` - If no translation is found
  """
  @callback lookup_lngettext(
              backend :: module(),
              locale :: binary,
              domain :: binary,
              msgctxt :: binary | nil,
              msgid :: binary,
              msgid_plural :: binary,
              plural_index :: non_neg_integer()
            ) ::
              {:ok, raw_msgstr :: binary} | {:error, :not_found}

  @doc """
  Returns a list of all known locales.

  ## Parameters

  * `backend` - The backend module implementing this behaviour

  ## Returns

  * A list of locale strings supported by this backend source
  """
  @callback known_locales(backend :: module()) :: [binary]

  @doc """
  Validates the options passed to the backend source at compile time.

  This function should validate the configuration options for the source and
  return the validated options. If validation fails, it should raise an exception.

  ## Example

      @impl true
      def validate_opts(opts) do
        case Keyword.fetch(opts, :repo) do
          {:ok, repo} when is_atom(repo) ->
            opts

          _ ->
            raise ArgumentError,
                  "Kanta Ecto adapter requires :repo option to be set to a module name"
        end
      end

  ## Returns

  * `Keyword.t()` - The validated options if successful.

  ## Raises

  * ArgumentError - If the options are invalid.
  """
  @callback validate_opts(opts :: Keyword.t()) :: Keyword.t()
end
