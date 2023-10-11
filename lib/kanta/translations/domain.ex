defmodule Kanta.Translations.Domain do
  @moduledoc """
  Gettext domain DB model
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Kanta.Translations.Message

  @all_fields ~w(name description color)a
  @required_fields ~w(name)a

  @type t() :: Kanta.Translations.DomainSpec.t()

  @derive {Jason.Encoder, only: [:id] ++ @all_fields}

  schema "kanta_domains" do
    field :name, :string
    field :description, :string
    field :color, :string

    has_many :messages, Message

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
end
