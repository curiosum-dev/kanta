defmodule Kanta.Translations.Message do
  @moduledoc """
  Gettext message DB model
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Kanta.Translations.{Context, Domain, PluralTranslation, SingularTranslation}

  @type t() :: Kanta.Translations.MessageSpec.t()

  @all_fields ~w(msgid message_type domain_id context_id)a
  @required_fields ~w(msgid message_type)a

  schema "kanta_messages" do
    field :msgid, :string
    field :message_type, Ecto.Enum, values: [:singular, :plural]

    belongs_to :domain, Domain
    belongs_to :context, Context

    has_many :singular_translations, SingularTranslation
    has_many :plural_translations, PluralTranslation

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
end
