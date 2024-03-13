defmodule Kanta.Gettext.Repo do
  alias Kanta.Utils.Compilation

  alias Kanta.Translations.{
    Context,
    Domain,
    Locale,
    Message,
    PluralTranslation,
    SingularTranslation
  }

  alias Kanta.Translations

  def init(_) do
    __MODULE__
  end

  def get_translation(locale, domain, msgctxt, msgid, opts) do
    if Compilation.compiling?() do
      msgid
    else
      do_get_translation(locale, domain, msgctxt, msgid, opts)
    end
  end

  defp do_get_translation(locale, domain, msgctxt, msgid, opts) do
    default_locale = Application.get_env(:kanta, :default_locale) || "en"

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
               domain_id: domain_id
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
          do_get_translation(default_locale, domain, msgctxt, msgid, opts)
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
        locale,
        domain,
        msgctxt,
        msgid,
        msgid_plural,
        plural_form,
        opts
      ) do
    if Compilation.compiling?() do
      if plural_form == 1, do: msgid, else: msgid_plural
    else
      do_get_plural_translation(
        locale,
        domain,
        msgctxt,
        msgid,
        msgid_plural,
        plural_form,
        opts
      )
    end
  end

  defp do_get_plural_translation(
         locale,
         domain,
         msgctxt,
         msgid,
         msgid_plural,
         plural_form,
         opts
       ) do
    default_locale = Application.get_env(:kanta, :default_locale) || "en"

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
               domain_id: domain_id
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
          do_get_plural_translation(
            default_locale,
            domain,
            msgctxt,
            msgid,
            msgid_plural,
            plural_form,
            opts
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
