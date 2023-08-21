defmodule Kanta.Translations.ContextSpec do
  @moduledoc """
  Includes type specs for context.
  """

  alias Kanta.Translations.{Context, Message}
  alias Kanta.Types

  @type t() :: %Context{
          id: Types.field(Types.id()),
          name: Types.field(String.t()),
          description: Types.field(String.t()),
          color: Types.field(String.t()),
          messages: [Message.t()],
          inserted_at: Types.field(NaiveDateTime.t()),
          updated_at: Types.field(NaiveDateTime.t())
        }
end
