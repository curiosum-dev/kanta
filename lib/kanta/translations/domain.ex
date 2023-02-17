defmodule Kanta.Translations.Domain do
  use Ecto.Schema
  import Ecto.Changeset

  alias Kanta.Translations.Message

  schema "kanta_domains" do
    field :name, :string

    has_many :messages, Message
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end
