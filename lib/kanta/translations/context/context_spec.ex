defmodule Kanta.Translations.ContextSpec do
  alias Kanta.Translations.{Context, Message}
  alias Kanta.Types

  @type t() :: %Context{
    id: Types.field(Types.id()),
    name: Types.field(String.t()),
    description: Types.field(String.t()),
    color: Types.field(String.t()),
    messages: [Message.t()],
    inserted_at: Types.field(DateTime.t()),
    updated_at: Types.field(DateTime.t())
  }
end
