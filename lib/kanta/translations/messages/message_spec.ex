defmodule Kanta.Translations.MessageSpec do
  @moduledoc """
  Includes type specs for message.
  """

  alias Kanta.Translations.{
    ApplicationSource,
    Context,
    Domain,
    Message,
    PluralTranslation,
    SingularTranslation
  }

  alias Kanta.Types

  @type t() :: %Message{
          id: Types.field(Types.id()),
          msgid: Types.field(String.t()),
          message_type: :singular | :plural,
          application_source: Types.field(ApplicationSource.t()),
          application_source_id: Types.field(Types.id()),
          domain: Types.field(Domain.t()),
          domain_id: Types.field(Types.id()),
          context: Types.field(Context.t()),
          context_id: Types.field(Types.id()),
          singular_translations: [SingularTranslation.t()],
          plural_translations: [PluralTranslation.t()],
          inserted_at: Types.field(NaiveDateTime.t()),
          updated_at: Types.field(NaiveDateTime.t())
        }
end
