defmodule Kanta.Translations.SingularTranslation do
  use Ecto.Schema
  import Ecto.Changeset
  alias Kanta.Translations.{Domain, Locale}

  schema "kanta_singular_translations" do
    belongs_to :locale, Locale
    belongs_to :domain, Domain
    field :msgctxt, :string
    field :msgid, :string
    field :previous_text, :string
    field :text, :string
  end

  def create_changeset(struct, params, locale, domain) do
    struct
    |> cast(params, [:msgctxt, :msgid, :previous_text, :text])
    |> put_assoc(:locale, locale)
    |> put_assoc(:domain, domain)
    |> validate_required([:locale, :domain, :msgid, :previous_text, :text])
    |> foreign_key_constraint(:locale)
    |> foreign_key_constraint(:domain)
  end

  def delete_changeset(struct, params) do
    struct
    |> cast(params, [:locale, :domain, :msgctxt, :msgid, :previous_text, :text])
    |> validate_required([:locale, :domain, :msgid])
    |> foreign_key_constraint(:locale)
    |> foreign_key_constraint(:domain)
  end
end
