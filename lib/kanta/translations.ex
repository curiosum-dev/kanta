defmodule Kanta.Translations do
  alias Kanta.Translations.{Domains, Locales, Messages, SingularTranslations}

  # DOMAINS
  defdelegate list_domains, to: Domains

  # MESSAGES
  defdelegate list_messages_by(params), to: Messages
  defdelegate get_message(id), to: Messages

  # LOCALES
  defdelegate list_locales, to: Locales
  defdelegate get_locale(id), to: Locales

  # TRANSLATIONS
  defdelegate list_singular_translations(params), to: SingularTranslations
  defdelegate get_singular_translation_by(params), to: SingularTranslations
  defdelegate create_singular_translation(attrs), to: SingularTranslations
  defdelegate update_singular_translation(id, attrs), to: SingularTranslations
  defdelegate delete_singular_translation(id), to: SingularTranslations
end
