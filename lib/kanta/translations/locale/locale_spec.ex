defmodule Kanta.Translations.LocaleSpec do
  @moduledoc """
  Includes type specs for locale.
  """

  alias Kanta.Translations.{Locale, SingularTranslation}
  alias Kanta.Types

  @type t() :: %Locale{
          id: Types.field(Types.id()),
          iso639_code: Types.field(String.t()),
          name: Types.field(String.t()),
          native_name: Types.field(String.t()),
          family: Types.field(String.t()),
          wiki_url: Types.field(String.t()),
          plurals_header: Types.field(String.t()),
          colors: Types.field([String.t()]),
          singular_translations: [SingularTranslation.t()],
          inserted_at: Types.field(NaiveDateTime.t()),
          updated_at: Types.field(NaiveDateTime.t())
        }
end
