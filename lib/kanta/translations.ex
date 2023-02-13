defmodule Kanta.Translations do
  alias Kanta.Translations.{Locales, SingularTranslations}

  # LOCALES
  defdelegate list_locales, to: Locales

  # TRANSLATIONS
  defdelegate create_singular_translation(singular_translation), to: SingularTranslations
  defdelegate get_singular_translation(singular_translation), to: SingularTranslations
  defdelegate delete_singular_translation(singular_translation), to: SingularTranslations
  defdelegate list_singular_translations(filters \\ []), to: SingularTranslations
end
