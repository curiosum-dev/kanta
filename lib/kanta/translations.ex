defmodule Kanta.Translations do
  @moduledoc """
  Main Kanta Translations context
  """

  alias Kanta.Translations.{
    ApplicationSources,
    Contexts,
    Domains,
    Locales,
    Messages,
    PluralTranslations,
    SingularTranslations
  }

  # APPLICATION SOURCES
  defdelegate list_application_sources(params \\ []), to: ApplicationSources
  defdelegate get_application_source(params), to: ApplicationSources
  defdelegate create_application_source(attrs), to: ApplicationSources
  defdelegate application_sources_empty?(), to: ApplicationSources

  # CONTEXTS
  defdelegate list_contexts(params \\ []), to: Contexts
  defdelegate get_context(params), to: Contexts
  defdelegate create_context(params), to: Contexts

  # DOMAINS
  defdelegate list_domains(params \\ []), to: Domains
  defdelegate get_domain(params \\ []), to: Domains
  defdelegate create_domain(attrs), to: Domains

  # MESSAGES
  defdelegate list_messages(params \\ []), to: Messages
  defdelegate get_message(params \\ []), to: Messages
  defdelegate get_messages_count(), to: Messages
  defdelegate create_message(attrs), to: Messages

  # LOCALES
  defdelegate list_locales(params \\ []), to: Locales
  defdelegate get_locale(params \\ []), to: Locales
  defdelegate update_locale(locale, attrs), to: Locales

  # TRANSLATIONS
  defdelegate list_plural_translations(params), to: PluralTranslations
  defdelegate get_plural_translation(params), to: PluralTranslations
  defdelegate create_plural_translation(attrs), to: PluralTranslations
  defdelegate update_plural_translation(translation, attrs), to: PluralTranslations

  defdelegate get_singular_translation(params), to: SingularTranslations
  defdelegate create_singular_translation(attrs), to: SingularTranslations
  defdelegate update_singular_translation(translation, attrs), to: SingularTranslations
end
