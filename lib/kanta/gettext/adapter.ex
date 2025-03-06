defmodule Kanta.Gettext.Adapter do
  @moduledoc """
  Kanta adapter used in *gettext functions from Kanta.Gettext.Macros.

  Handles translation lookups in cache and DB for both singular and plural forms.
  """

  require Logger

  alias Kanta.Translations.{
    Context,
    Domain,
    Locale,
    Message,
    PluralTranslation,
    SingularTranslation
  }

  alias Kanta.Translations

  def get_singular_translation(backend, domain, msgctxt, msgid, bindings) do
    locale = Gettext.get_locale(backend)

    get_singular_translation(backend, locale, domain, msgctxt, msgid, bindings)
  end

  def get_singular_translation(backend, locale, domain, msgctxt, msgid, bindings) do
    default_locale = Application.get_env(:kanta, :default_locale) || "en"
    domain = if is_atom(domain), do: Atom.to_string(domain), else: domain

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
         {:ok, %SingularTranslation{translated_text: text}} <-
           Translations.get_singular_translation(
             filter: [
               locale_id: locale_id,
               message_id: message_id
             ]
           ) do
      if is_nil(text) do
        if locale != default_locale do
          get_singular_translation(backend, default_locale, domain, msgctxt, msgid, bindings)
        else
          :not_found
        end
      else
        apply_bindings(text, bindings)
      end
    else
      _ ->
        :not_found
    end
  end

  def get_plural_translation(
        backend,
        domain,
        msgctxt,
        msgid,
        msgid_plural,
        plural_form,
        bindings
      ) do
    locale = Gettext.get_locale(backend)

    get_plural_translation(
      backend,
      locale,
      domain,
      msgctxt,
      msgid,
      msgid_plural,
      plural_form,
      bindings
    )
  end

  def get_plural_translation(
        backend,
        locale,
        domain,
        msgctxt,
        msgid,
        msgid_plural,
        plural_form,
        bindings
      ) do
    default_locale = Application.get_env(:kanta, :default_locale) || "en"
    domain = if is_atom(domain), do: Atom.to_string(domain), else: domain

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
         nplural_index <- Expo.PluralForms.index(plurals_options, plural_form),
         {:ok, %PluralTranslation{translated_text: text}} <-
           Translations.get_plural_translation(
             filter: [
               locale_id: locale_id,
               message_id: message_id,
               nplural_index: nplural_index
             ]
           ) do
      if is_nil(text) do
        if locale != default_locale do
          get_plural_translation(
            backend,
            default_locale,
            domain,
            msgctxt,
            msgid,
            msgid_plural,
            plural_form,
            bindings
          )
        else
          :not_found
        end
      else
        bindings = Map.put(bindings, :count, plural_form)
        apply_bindings(text, bindings)
      end
    else
      _ ->
        :not_found
    end
  end

  defp maybe_get_context_id(nil), do: {:ok, nil}

  defp maybe_get_context_id(msgctxt) do
    case Translations.get_context(filter: [name: msgctxt]) do
      {:ok, %Context{} = context} -> {:ok, context.id}
      _ -> {:ok, nil}
    end
  end

  @spec apply_bindings(String.t(), Keyword.t() | map()) :: {:ok, String.t()} | :not_found
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

        :not_found
    end
  end
end
