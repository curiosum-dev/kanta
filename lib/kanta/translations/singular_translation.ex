defmodule Kanta.Translations.SingularTranslation do
  @moduledoc """
  Singular translation DB model
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Kanta.Translations.{Locale, Message}

  @all_fields ~w(original_text translated_text locale_id message_id)a
  @required_fields ~w(message_id locale_id)a

  schema "kanta_singular_translations" do
    field :original_text, :string
    field :translated_text, :string

    belongs_to :locale, Locale
    belongs_to :message, Message

    timestamps()
  end

  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @all_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:locale_id)
    |> foreign_key_constraint(:message_id)
  end
end
