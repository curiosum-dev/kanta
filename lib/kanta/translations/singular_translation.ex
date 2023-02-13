defmodule Kanta.Translations.SingularTranslation do
  use Ecto.Schema
  import Ecto.Changeset
  alias Kanta.Translations.{Domain, Locale}

  @all_fields ~w(msgctxt msgid previous_text text locale_id domain_id)a
  @required_fields ~w(msgid)a

  schema "kanta_singular_translations" do
    belongs_to :locale, Locale
    belongs_to :domain, Domain
    field :msgctxt, :string
    field :msgid, :string
    field :previous_text, :string
    field :text, :string
  end

  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @all_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:locale)
    |> foreign_key_constraint(:domain)
  end
end
