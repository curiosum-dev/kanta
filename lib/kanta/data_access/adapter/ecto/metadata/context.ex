defmodule Kanta.DataAccess.Adapter.Ecto.Metadata.Context do
  @moduledoc "Ecto Schema for Context Metadata"

  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:name, :color, :description],
    sortable: [:name],
    default_order: %{
      order_by: [:name],
      order_directions: [:asc]
    },
    default_limit: 20,
    max_limit: 100
  }

  schema "contexts" do
    field :name, :string
    field :description, :string
    field :color, :string
  end

  @required_fields [:name, :description, :color]
  @all_fields @required_fields

  def changeset(context \\ %__MODULE__{}, attrs) do
    context
    |> cast(attrs, @all_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:name)
  end
end
