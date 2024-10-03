defmodule Kanta.Translations.Locale do
  @moduledoc """
  Locale DB model
  """

  use Kanta.Schema
  import Ecto.Changeset
  alias Kanta.Translations.SingularTranslation

  @required_fields ~w(iso639_code name native_name)a
  @optional_fields ~w(plurals_header family wiki_url colors)a

  @type t() :: Kanta.Translations.LocaleSpec.t()

  @derive {Jason.Encoder, only: [:id] ++ @required_fields ++ @optional_fields}

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
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
