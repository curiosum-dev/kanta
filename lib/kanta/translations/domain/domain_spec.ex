defmodule Kanta.Translations.DomainSpec do
  alias Kanta.Translations.{Domain, Message}
  alias Kanta.Types

  @type t() :: %Domain{
    id: Types.field(Types.id()),
    name: Types.field(String.t()),
    description: Types.field(String.t()),
    color: Types.field(String.t()),
    messages: [Message.t()],
    inserted_at: Types.field(DateTime.t()),
    updated_at: Types.field(DateTime.t())
  }
end
