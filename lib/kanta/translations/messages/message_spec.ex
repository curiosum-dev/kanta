defmodule Kanta.Translations.MessageSpec do
  alias Kanta.Translations.{Context, Domain, Message, PluralTranslation, SingularTranslation}
  alias Kanta.Types

  @type t() :: %Message{
    id: Types.field(Types.id()),
    msgid: Types.field(String.t()),
    message_type: :singular | :plural,
    domain: Types.field(Domain.t()),
    domain_id: Types.field(Types.id()),
    context: Types.field(Context.t()),
    context_id: Types.field(Types.id()),
    singular_translations: [SingularTranslation.t()],
    plural_translations: [PluralTranslation.t()],
    inserted_at: Types.field(DateTime.t()),
    updated_at: Types.field(DateTime.t())
  }
end
