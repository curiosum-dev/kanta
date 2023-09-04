defmodule Kanta.Translations.SingularTranslationSpec do
  @moduledoc """
  Includes type specs for singular translations.
  """

  alias Kanta.Translations.{Locale, Message, SingularTranslation}
  alias Kanta.Types

  @type t() :: %SingularTranslation{
          id: Types.field(Types.id()),
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
