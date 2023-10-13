defmodule Kanta.Translations.Domain do
  @moduledoc """
  Gettext domain DB model
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Kanta.Translations.Message

  @required_fields ~w(name)a
  @optional_fields ~w(description color)a

  @type t() :: Kanta.Translations.DomainSpec.t()

  @derive {Jason.Encoder, only: [:id] ++ @required_fields ++ @optional_fields}

  schema "kanta_domains" do
    field :name, :string
    field :description, :string
    field :color, :string

    has_many :messages, Message

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
