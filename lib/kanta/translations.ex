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
  defdelegate create_application_source(attrs, opts \\ []), to: ApplicationSources
  defdelegate change_application_source(attrs, params \\ %{}), to: ApplicationSources
  defdelegate application_sources_empty?(), to: ApplicationSources

  defdelegate update_application_source(application_source, attrs, opts \\ []),
    to: ApplicationSources

  # CONTEXTS
  defdelegate list_contexts(params \\ []), to: Contexts
  defdelegate list_all_contexts(params \\ []), to: Contexts
  defdelegate get_context(params), to: Contexts
  defdelegate create_context(params, opts \\ []), to: Contexts

  # DOMAINS
  defdelegate list_domains(params \\ []), to: Domains
  defdelegate list_all_domains(params \\ []), to: Domains
  defdelegate get_domain(params \\ []), to: Domains
  defdelegate create_domain(attrs, opts \\ []), to: Domains

  # MESSAGES
  defdelegate list_messages(params \\ []), to: Messages
  defdelegate list_all_messages(params \\ []), to: Messages
  defdelegate get_message(params \\ []), to: Messages
  defdelegate get_messages_count(), to: Messages
  defdelegate create_message(attrs, opts \\ []), to: Messages

  # LOCALES
  defdelegate list_locales(params \\ []), to: Locales
  defdelegate get_locale(params \\ []), to: Locales
  defdelegate update_locale(locale, attrs, opts \\ []), to: Locales
  defdelegate create_locale(attrs, opts \\ []), to: Locales

  # TRANSLATIONS
  defdelegate list_plural_translations(params \\ []), to: PluralTranslations
  defdelegate get_plural_translation(params), to: PluralTranslations
  defdelegate create_plural_translation(attrs, opts \\ []), to: PluralTranslations
  defdelegate update_plural_translation(translation, attrs, opts \\ []), to: PluralTranslations

  defdelegate list_singular_translations(params \\ []), to: SingularTranslations
  defdelegate get_singular_translation(params), to: SingularTranslations
  defdelegate create_singular_translation(attrs, opts \\ []), to: SingularTranslations

  defdelegate update_singular_translation(translation, attrs, opts \\ []),
    to: SingularTranslations
end
