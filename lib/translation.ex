defmodule Kanta.Translation do
  use Ecto.Schema

  import Ecto.Changeset

  schema "kanta_translations" do
    field(:locale, :string)
    field(:domain, :string)
    field(:msgctxt, :string)
    field(:msgid, :string)
    field(:translated, :string)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:locale, :domain, :msgctxt, :msgid, :translated])
    |> validate_required([:locale, :msgid, :translated])
  end
end
