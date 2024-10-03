defmodule Kanta.Translations.Message do
  @moduledoc """
  Gettext message DB model
  """

  use Kanta.Schema
  import Ecto.Changeset

  alias Kanta.Translations.{
    ApplicationSource,
    Context,
    Domain,
    PluralTranslation,
    SingularTranslation
  }

  @required_fields ~w(msgid message_type)a
  @optional_fields ~w(domain_id context_id application_source_id)a
  @relations ~w(domain context singular_translations plural_translations)a

  @type t() :: Kanta.Translations.MessageSpec.t()

  @derive {Jason.Encoder, only: [:id] ++ @required_fields ++ @optional_fields ++ @relations}

  schema "kanta_messages" do
    field :msgid, :string
    field :message_type, Ecto.Enum, values: [:singular, :plural]

    belongs_to :domain, Domain
    belongs_to :context, Context
    belongs_to :application_source, ApplicationSource

    has_many :singular_translations, SingularTranslation
    has_many :plural_translations, PluralTranslation

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
