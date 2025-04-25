defmodule Kanta.DataAccess.Adapter.Ecto.Metadata.ApplicationSource do
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

  schema "domains" do
    field :name, :string
    field :description, :string
    field :color, :string
  end

  @required_fields [:name]
  @optional_fields [:description, :color]
  @all_fields @required_fields ++ @optional_fields

  def changeset(domain \\ %__MODULE__{}, attrs) do
    domain
    |> cast(attrs, @all_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:name)
  end
end
