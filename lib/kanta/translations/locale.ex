defmodule Kanta.Translations.Locale do
  @moduledoc """
  Locale DB model
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Kanta.Translations.SingularTranslation

  @all_fields ~w(iso639_code name plurals_header native_name family wiki_url colors)a
  @required_fields ~w(iso639_code name native_name)a

  @type t() :: Kanta.Translations.LocaleSpec.t()

  @derive {Jason.Encoder, only: [:id] ++ @all_fields}

  schema "kanta_locales" do
    field :iso639_code, :string
    field :name, :string
    field :native_name, :string
    field :family, :string
    field :wiki_url, :string
    field :plurals_header, :string

    field :colors, {:array, :string}

    has_many :singular_translations, SingularTranslation

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
end
