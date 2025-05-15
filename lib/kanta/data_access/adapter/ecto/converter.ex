defmodule Kanta.DataAccess.Adapter.Ecto.Converter do
  @moduledoc """
  Provides conversion functions between Ecto schema structs and domain model types.
  """

  alias Kanta.DataAccess.Adapter.Ecto.Singular, as: SingularSchema
  alias Kanta.DataAccess.Adapter.Ecto.Plural, as: PluralSchema
  alias Kanta.DataAccess.Model.Singular, as: SingularModel
  alias Kanta.DataAccess.Model.Plural, as: PluralModel
  alias Kanta.DataAccess.Model.Plurals, as: PluralsModel
  alias Kanta.DataAccess.Adapter.Ecto.Metadata.Domain, as: DomainSchema
  alias Kanta.DataAccess.Adapter.Ecto.Metadata.Context, as: ContextSchema
  alias Kanta.DataAccess.Model.Metadata.Domain, as: DomainModel
  alias Kanta.DataAccess.Model.Metadata.Context, as: ContextModel

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
  @spec to_model(struct() | nil) ::
          SingularModel.t()
          | PluralModel.t()
          | DomainModel.t()
          | ContextModel.t()
          | struct()
          | nil
  def to_model(nil), do: nil
  def to_model(%SingularSchema{} = struct), do: to_singular(struct)
  def to_model(%PluralSchema{} = struct), do: to_plural(struct)
  def to_model(%DomainSchema{} = struct), do: to_domain(struct)
  def to_model(%ContextSchema{} = struct), do: to_context(struct)
  def to_model(other), do: other

  @doc """
  Converts a list of Ecto schema structs to their corresponding domain models.

  ## Parameters
    * `structs` - A list of Ecto schema structs

  ## Returns
    * A list of corresponding domain model maps
  """
  @spec to_models([struct()]) :: [
          SingularModel.t() | PluralModel.t() | DomainModel.t() | ContextModel.t() | struct()
        ]
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
    %SingularModel{
      id: schema.id,
      locale: schema.locale,
      domain: schema.domain,
      msgctxt: schema.msgctxt,
      msgid: schema.msgid,
      msgstr: schema.msgstr,
      msgstr_origin: schema.msgstr_origin
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
    %PluralModel{
      id: schema.id,
      locale: schema.locale,
      domain: schema.domain,
      msgctxt: schema.msgctxt,
      msgid: schema.msgid,
      msgid_plural: schema.msgid_plural,
      plural_index: schema.plural_index,
      msgstr: schema.msgstr,
      msgstr_origin: schema.msgstr_origin,
      plural_id: schema.plural_id
    }
  end

  @spec to_plural([%PluralSchema{}]) :: [PluralModel.t()]
  def to_plural(schemas) when is_list(schemas) do
    Enum.map(schemas, &to_plural/1)
  end

  @doc """
  Converts a list of PluralSchema structs to a PluralsModel struct.

  This function groups related plural forms into a single PluralsModel struct
  that contains all the plural translations.

  ## Parameters
    * `schemas` - A list of PluralSchema structs with the same plural_id

  ## Returns
    * A PluralsModel struct containing all related plural translations
    * A list of PluralModel structs if the input list is empty
  """
  @spec to_plurals([%PluralSchema{}]) :: PluralsModel.t()
  def to_plurals(schemas) when is_list(schemas) and length(schemas) > 0 do
    plural_translations = Enum.map(schemas, &to_plural/1)

    # Get data from any translation
    plural = %PluralModel{} = hd(plural_translations)

    %PluralsModel{
      id: plural.plural_id,
      locale: plural.locale,
      domain: plural.domain,
      msgctxt: plural.msgctxt,
      msgid: plural.msgid,
      msgid_plural: plural.msgid_plural,
      plural_translations: plural_translations
    }
  end

  @spec to_plurals([%PluralSchema{}]) :: [PluralModel.t()]
  def to_plurals(schemas) when is_list(schemas) do
    Enum.map(schemas, &to_plural/1)
  end

  @doc """
  Converts a DomainSchema struct to a Domain model map.

  ## Parameters
    * `schema` - A DomainSchema struct or list of DomainSchema structs

  """
  @spec to_domain(%DomainSchema{}) :: DomainModel.t()
  def to_domain(%DomainSchema{} = schema) do
    %DomainModel{
      id: schema.id,
      name: schema.name,
      description: schema.description,
      color: schema.color
    }
  end

  @spec to_domain([%DomainSchema{}]) :: [DomainModel.t()]
  def to_domain(schemas) when is_list(schemas) do
    Enum.map(schemas, &to_domain/1)
  end

  @doc """
  Converts a ContextSchema struct to a Context model map.

  ## Parameters
    * `schema` - A ContextSchema struct or list of ContextSchema structs

  """
  @spec to_context(%ContextSchema{}) :: ContextModel.t()
  def to_context(%ContextSchema{} = schema) do
    %ContextModel{
      id: schema.id,
      name: schema.name,
      description: schema.description,
      color: schema.color
    }
  end

  @spec to_context([%ContextSchema{}]) :: [ContextModel.t()]
  def to_context(schemas) when is_list(schemas) do
    Enum.map(schemas, &to_context/1)
  end
end
