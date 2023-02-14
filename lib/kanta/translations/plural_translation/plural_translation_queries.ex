defmodule Kanta.Translations.PluralTranslationQueries do
  use Kanta.Query,
    module: Kanta.Translations.PluralTranslation,
    binding: :singular_translation
end
