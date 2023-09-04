defmodule Kanta.Translations.PluralTranslationSpec do
  @moduledoc """
  Includes type specs for plural translations.
  """

  alias Kanta.Translations.{Locale, Message, PluralTranslation}
  alias Kanta.Types

  @type t() :: %PluralTranslation{
          id: Types.field(Types.id()),
          nplural_index: Types.field(integer()),
          original_text: Types.field(String.t()),
          translated_text: Types.field(String.t()),
          locale: Types.field(Locale.t()),
          locale_id: Types.field(Types.id()),
          message: Types.field(Message.t()),
          message_id: Types.field(Types.id()),
          inserted_at: Types.field(NaiveDateTime.t()),
          updated_at: Types.field(NaiveDateTime.t())
        }
end
