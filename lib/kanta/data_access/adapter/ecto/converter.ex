defmodule Kanta.DataAccess.Adapter.Ecto.Converter do
  @moduledoc """
  Provides conversion functions between Ecto schema structs and domain model types.
  """

  alias Kanta.DataAccess.Adapter.Ecto.Singular, as: SingularSchema
  alias Kanta.DataAccess.Adapter.Ecto.Plural, as: PluralSchema
  alias Kanta.DataAccess.Model.Singular, as: SingularModel
  alias Kanta.DataAccess.Model.Plural, as: PluralModel

  @doc """
  Converts an Ecto schema struct to its corresponding domain model.

  This function dispatches to the appropriate conversion function based on the
  type of the provided struct.

  ## Parameters
    * `struct` - An Ecto schema struct

  ## Returns
    * The corresponding domain model map
    * `nil` if the input is nil
  """
  @spec to_model(struct() | nil) :: map() | nil
  def to_model(nil), do: nil
  def to_model(%SingularSchema{} = struct), do: to_singular(struct)
  def to_model(%PluralSchema{} = struct), do: to_plural(struct)
  def to_model(other), do: other

  @doc """
  Converts a list of Ecto schema structs to their corresponding domain models.

  ## Parameters
    * `structs` - A list of Ecto schema structs

  ## Returns
    * A list of corresponding domain model maps
  """
  @spec to_models([struct()]) :: [map()]
  def to_models(structs) when is_list(structs) do
    Enum.map(structs, &to_model/1)
  end

  @doc """
  Converts a SingularSchema struct to a Singular model map.

  ## Parameters
    * `schema` - A SingularSchema struct or list of SingularSchema structs

  ## Returns
    * A map representing a Singular model or a list of Singular model maps
  """
  @spec to_singular(%SingularSchema{}) :: SingularModel.t()
  def to_singular(%SingularSchema{} = schema) do
    %{
      id: schema.id,
      locale: schema.locale,
      domain: schema.domain,
      msgctxt: schema.msgctxt,
      msgid: schema.msgid,
      msgstr: schema.msgstr,
      msgstr_origin: schema.msgstr_origin,
      type: :singular
    }
  end

  @spec to_singular([%SingularSchema{}]) :: [SingularModel.t()]
  def to_singular(schemas) when is_list(schemas) do
    Enum.map(schemas, &to_singular/1)
  end

  @doc """
  Converts a PluralSchema struct to a Plural model map.

  ## Parameters
    * `schema` - A PluralSchema struct or list of PluralSchema structs

  ## Returns
    * A map representing a Plural model or a list of Plural model maps
  """
  @spec to_plural(%PluralSchema{}) :: PluralModel.t()
  def to_plural(%PluralSchema{} = schema) do
    %{
      id: schema.id,
      locale: schema.locale,
      domain: schema.domain,
      msgctxt: schema.msgctxt,
      msgid: schema.msgid,
      msgid_plural: schema.msgid_plural,
      plural_index: schema.plural_index,
      msgstr: schema.msgstr,
      msgstr_origin: schema.msgstr_origin,
      type: :plural
    }
  end

  @spec to_plural([%PluralSchema{}]) :: [PluralModel.t()]
  def to_plural(schemas) when is_list(schemas) do
    Enum.map(schemas, &to_plural/1)
  end
end
