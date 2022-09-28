defmodule Kanta.Translations.LocaleQueries do
  use Kanta.Query,
    module: Kanta.Translations.Locale,
    binding: :locale
end
