defmodule Kanta.Translations.Domain do
  @moduledoc """
  Gettext domain DB model
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Kanta.Translations.Message

  schema "kanta_domains" do
    field :name, :string
    field :description, :string
    field :color, :string

    has_many :messages, Message

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:name, :description, :color])
    |> validate_required([:name])
  end
end
