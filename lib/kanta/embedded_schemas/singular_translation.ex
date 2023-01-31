defmodule Kanta.EmbeddedSchemas.SingularTranslation do
  use Ecto.Schema
  import Ecto.Changeset
  alias Kanta.EmbeddedSchemas.SingularTranslation

  embedded_schema do
    field :locale, :string
    field :domain, :string
    field :msgctxt, :string
    field :msgid, :string
    field :previous_text, :string
    field :text, :string
  end

  def new(params) do
    %SingularTranslation{}
    |> cast(params, [:locale, :domain, :msgctxt, :msgid, :previous_text, :text])
    |> validate_required([:locale, :domain, :msgid, :text])
    |> apply_changes()
  end
end
