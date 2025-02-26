defmodule Kanta.Gettext.Adapter do
  @moduledoc """
  Kanta adapter used in *gettext functions from Kanta.Gettext.Macros.

  Handles translation lookups in cache and DB for both singular and plural forms.

  If it does not found a translation for a given locale,
  checks if an entry for a default locale (usually "en") exists.
  """

  alias Kanta.Translations.{
    Context,
    Domain,
    Locale,
    Message,
    PluralTranslation,
    SingularTranslation
  }

  alias Kanta.Translations

  def get_singular_translation(backend, domain, msgctxt, msgid) do
    locale = Gettext.get_locale(backend)

    get_singular_translation(backend, locale, domain, msgctxt, msgid)
  end

  def get_singular_translation(backend, locale, domain, msgctxt, msgid) do
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
          get_singular_translation(backend, default_locale, domain, msgctxt, msgid)
        else
          :not_found
        end
      else
        {:ok, text}
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
        plural_form
      ) do
    locale = Gettext.get_locale(backend)

    get_plural_translation(
      backend,
      locale,
      domain,
      msgctxt,
      msgid,
      msgid_plural,
      plural_form
    )
  end

  def get_plural_translation(
        backend,
        locale,
        domain,
        msgctxt,
        msgid,
        msgid_plural,
        plural_form
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
            plural_form
          )
        else
          :not_found
        end
      else
        {:ok, text}
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
end
