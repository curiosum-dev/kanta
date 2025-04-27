defmodule Kanta.DataAccess.Adapter.Ecto.Singular do
  @moduledoc "Ecto Schema for Singular Translations"
  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:locale, :domain, :msgctxt, :msgid, :msgstr_origin],
    sortable: [:locale, :domain, :msgid],
    default_order: %{
      order_by: [:locale, :domain, :msgid],
      order_directions: [:asc, :asc, :asc]
    },
    default_limit: 20,
    max_limit: 100
  }

  schema "kanta_singulars" do
    field :locale, :string
    field :domain, :string
    # Can be nil
    field :msgctxt, :string
    field :msgid, :string
    # The actual translation
    field :msgstr, :string
    field :msgstr_origin, :string
    # Uncomment if you add timestamps to your migration
    timestamps()
  end

  # --- Changeset Functions ---
  @create_fields [:locale, :domain, :msgctxt, :msgid, :msgstr, :msgstr_origin]
  @required_create_fields [:locale, :domain, :msgid]
  @unique_key_fields [:locale, :domain, :msgctxt, :msgid]
  @update_fields [:locale, :domain, :msgctxt, :msgid, :msgstr, :msgstr_origin]

  def unique_fields, do: @unique_key_fields
  def msgstr_origin, do: :msgstr_origin
  def msgstr, do: :msgstr

  def create_changeset(struct \\ %__MODULE__{}, params) do
    struct
    |> cast(params, @create_fields)
    |> validate_required(@required_create_fields)
    # Add index name if needed
    |> unique_constraint(@unique_key_fields, name: :singulars_unique_key_index)
  end

  def update_changeset(struct, params) do
    struct
    |> cast(params, @update_fields)
    # Add index name if needed
    |> unique_constraint(@unique_key_fields, name: :singulars_unique_key_index)
  end

  def changeset(struct, params) do
    cast(struct, params, @create_fields ++ @update_fields)
  end
end
