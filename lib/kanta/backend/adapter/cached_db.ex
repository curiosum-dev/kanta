defmodule Kanta.Backend.Adapter.CachedDB do
  @moduledoc """
  Kanta adapter used in *gettext functions from Kanta.Gettext.Macros.

  Handles translation lookups in cache and DB for both singular and plural forms.
  """

  require Logger
  @behaviour Kanta.Backend.Adapter

  alias Kanta.Translations.{
    Context,
    Domain,
    Locale,
    Message,
    PluralTranslation,
    SingularTranslation
  }

  alias Kanta.Translations

  @doc """
  Translates a message with the given locale, domain, context, and message ID.

  ## Parameters
    * `locale` - ISO-639 code for the locale
    * `domain` - Name of the translation domain
    * `msgctxt` - Optional context for the message
    * `msgid` - Message ID to translate
    * `bindings` - Map or keyword list of variables to interpolate

  ## Returns
    * `{:ok, translation}` - When translation is found
    * `{:error, :not_found}` - When translation is not found
  """
  @impl true
  def lgettext(locale, domain, msgctxt, msgid, bindings) do
    with {:ok, %Locale{id: locale_id}} <-
           Translations.get_locale(filter: [iso639_code: locale]),
         {:ok, %Domain{id: domain_id}} <-
           Translations.get_domain(filter: [name: domain]),
         {:ok, context_id} <- maybe_get_context_id(msgctxt),
         {:ok, %Message{id: message_id}} <-
           Translations.get_message(
             filter: [
               msgid: msgid,
               context_id: context_id,
               domain_id: domain_id,
               application_source_id: nil
             ]
           ),
         {:ok, %SingularTranslation{translated_text: text}} when not is_nil(text) <-
           Translations.get_singular_translation(
             filter: [
               locale_id: locale_id,
               message_id: message_id
             ]
           ),
         {:ok, interpolated} <- apply_bindings(text, bindings) do
      {:ok, interpolated}
    else
      _ -> {:error, :not_found}
    end
  end

  @doc """
  Translates a plural message with the given locale, domain, context, message IDs, count and bindings.

  ## Parameters
    * `locale` - ISO-639 code for the locale
    * `domain` - Name of the translation domain
    * `msgctxt` - Optional context for the message
    * `msgid` - Singular message ID
    * `msgid_plural` - Plural message ID
    * `n` - Count to determine which plural form to use
    * `bindings` - Map or keyword list of variables to interpolate

  ## Returns
    * `{:ok, translation}` - When translation is found
    * `{:error, :not_found}` - When translation is not found
  """
  @impl true
  def lngettext(locale, domain, msgctxt, _msgid, msgid_plural, n, bindings) do
    with {:ok, %Locale{id: locale_id, plurals_header: plurals_header}} <-
           Translations.get_locale(filter: [iso639_code: locale]),
         {:ok, %Domain{id: domain_id}} <-
           Translations.get_domain(filter: [name: domain]),
         {:ok, context_id} <- maybe_get_context_id(msgctxt),
         {:ok, %Message{id: message_id}} <-
           Translations.get_message(
             filter: [
               msgid: msgid_plural,
               context_id: context_id,
               domain_id: domain_id,
               application_source_id: nil
             ]
           ),
         {:ok, plurals_options} <- Expo.PluralForms.parse(plurals_header),
         nplural_index <- Expo.PluralForms.index(plurals_options, n),
         {:ok, %PluralTranslation{translated_text: text}} when not is_nil(text) <-
           Translations.get_plural_translation(
             filter: [
               locale_id: locale_id,
               message_id: message_id,
               nplural_index: nplural_index
             ]
           ),
         {:ok, interpolated} <- apply_bindings(text, Map.put(bindings, :count, n)) do
      {:ok, interpolated}
    else
      _ -> {:error, :not_found}
    end
  end

  defp maybe_get_context_id(nil), do: {:ok, nil}

  defp maybe_get_context_id(msgctxt) do
    case Translations.get_context(filter: [name: msgctxt]) do
      {:ok, %Context{} = context} -> {:ok, context.id}
      _ -> {:ok, nil}
    end
  end

  @spec apply_bindings(String.t(), Keyword.t() | map()) ::
          {:ok, String.t()} | {:error, :not_found}
  defp apply_bindings(text, bindings) when is_list(bindings) do
    apply_bindings(text, Map.new(bindings))
  end

  defp apply_bindings(text, bindings) do
    case Gettext.Interpolation.Default.runtime_interpolate(text, bindings) do
      {:ok, interpolated} ->
        {:ok, interpolated}

      {:missing_bindings, partially_interpolated_message, missing_bindings} ->
        Logger.warning("[Kanta]: Missing bindings for translation", %{
          text: text,
          partially_interpolated_message: partially_interpolated_message,
          missing_bindings: missing_bindings
        })

        {:error, :not_found}
    end
  end
end
