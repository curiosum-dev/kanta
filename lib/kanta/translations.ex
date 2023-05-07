defmodule Kanta.Translations do
  alias Kanta.Translations.{
    Contexts,
    Domains,
    Locales,
    Messages,
    PluralTranslations,
    SingularTranslations
  }

  # CONTEXTS
  defdelegate list_contexts, to: Contexts
  defdelegate get_context(id), to: Contexts
  defdelegate get_context_by(params), to: Contexts

  # DOMAINS
  defdelegate list_domains, to: Domains
  defdelegate get_domain(id), to: Domains
  defdelegate get_domain_by(params), to: Domains

  # MESSAGES
  defdelegate list_messages_by(params), to: Messages
  defdelegate get_messages_count, to: Messages
  defdelegate get_message(id), to: Messages
  defdelegate get_message_by(params), to: Messages

  # LOCALES
  defdelegate list_locales, to: Locales
  defdelegate get_locale(id), to: Locales
  defdelegate get_locale_translation_progress(id), to: Locales
  defdelegate get_locale_by(params), to: Locales

  # TRANSLATIONS
  defdelegate list_plural_translations_by(params), to: PluralTranslations

  defdelegate get_singular_translation_by(params), to: SingularTranslations
  defdelegate get_plural_translation_by(params), to: PluralTranslations

  defdelegate create_singular_translation(attrs), to: SingularTranslations
  defdelegate update_singular_translation(id, attrs), to: SingularTranslations
  defdelegate update_plural_translation(id, attrs), to: PluralTranslations
end
