defmodule Kanta.Translations do
  alias Kanta.Translations.SingularTranslations

  defdelegate create_singular_translation(singular_translation), to: SingularTranslations
  defdelegate get_singular_translation(singular_translation), to: SingularTranslations
  defdelegate delete_singular_translation(singular_translation), to: SingularTranslations
  defdelegate list_singular_translations(filters \\ []), to: SingularTranslations
  defdelegate list_singular_translations_with_text_not_null(), to: SingularTranslations
end
