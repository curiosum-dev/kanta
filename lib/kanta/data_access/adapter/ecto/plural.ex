defmodule Kanta.DataAccess.Adapter.Ecto.Plural do
  @moduledoc "Ecto Schema for Plural Translations"
  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:locale, :domain, :msgctxt, :msgid, :msgid_plural, :plural_index, :msgstr_origin],
    sortable: [:locale, :domain, :msgid, :plural_index],
    default_order: %{
      order_by: [:locale, :domain, :msgid, :plural_index],
      order_directions: [:asc, :asc, :asc, :asc]
    },
    default_limit: 20,
    max_limit: 100
  }

  schema "kanta_plurals" do
    field :locale, :string
    field :domain, :string, default: "default"
    field :msgctxt, :string
    field :msgid, :string
    field :msgid_plural, :string
    field :plural_index, :integer
    field :msgstr, :string
    field :msgstr_origin, :string
    field :plural_id, :string
    # Uncomment if you add timestamps
    timestamps()
  end

  # --- Changeset Functions ---
  @create_fields [
    :locale,
    :domain,
    :msgctxt,
    :msgid,
    :msgid_plural,
    :plural_index,
    :msgstr,
    :msgstr_origin,
    :plural_id
  ]
  @required_create_fields [:locale, :domain, :msgid, :msgid_plural, :plural_index, :plural_id]
  @unique_key_fields [:locale, :domain, :msgctxt, :msgid, :msgid_plural, :plural_index]
  @update_fields [
    :locale,
    :domain,
    :msgid,
    :msgid_plural,
    :plural_index,
    :msgstr,
    :msgstr_origin,
    :plural_id
  ]

  def msgstr_origin(), do: :msgstr_origin
  def msgstr(), do: :msgstr
  def unique_fields(), do: @unique_key_fields

  def create_changeset(struct \\ %__MODULE__{}, params) do
    struct
    |> cast(params, @create_fields)
    |> validate_required(@required_create_fields)
    |> validate_number(:plural_index, greater_than_or_equal_to: 0)
    # Add index name if needed
    |> unique_constraint(@unique_key_fields, name: :plurals_unique_key_index)
  end

  def update_changeset(struct, params) do
    create_changeset(struct, params)
  end

  def changeset(struct, params) do
    cast(struct, params, @create_fields ++ @update_fields)
  end
end
