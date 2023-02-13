defmodule Kanta.Translations do
  alias Kanta.Translations.{Domains, Locales, Messages, SingularTranslations}

  # DOMAINS
  defdelegate list_domains, to: Domains

  # MESSAGES
  defdelegate list_messages_by_domain(domain_id), to: Messages

  # LOCALES
  defdelegate list_locales, to: Locales
  defdelegate get_locale(id), to: Locales

  # TRANSLATIONS
  defdelegate create_singular_translation(singular_translation), to: SingularTranslations
  defdelegate get_singular_translation(singular_translation), to: SingularTranslations
  defdelegate delete_singular_translation(singular_translation), to: SingularTranslations
  defdelegate list_singular_translations(filters \\ []), to: SingularTranslations
end
