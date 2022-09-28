defmodule Kanta.Translations.Domain do
  use Ecto.Schema
  import Ecto.Changeset
  alias Kanta.Translations.SingularTranslation

  schema "kanta_domains" do
    field :name, :string
    has_many :singular_translations, SingularTranslation
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end
