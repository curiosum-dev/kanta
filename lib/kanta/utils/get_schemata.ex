defmodule Kanta.Utils.GetSchemata do
  @moduledoc false

  alias Kanta.Specs.SchemataSpec

  alias Kanta.Translations.{
    Context,
    Domain,
    Locale,
    Message,
    PluralTranslation,
    SingularTranslation
  }

  @schemata [
    {"contexts", %{schema: Context, conflict_target: [:name]}},
    {"domains", %{schema: Domain, conflict_target: [:name]}},
    {"locales", %{schema: Locale, conflict_target: [:iso639_code]}},
    {"messages", %{schema: Message, conflict_target: [:id]}},
    {"singular_translations", %{schema: SingularTranslation, conflict_target: [:id]}},
    {"plural_translations", %{schema: PluralTranslation, conflict_target: [:id]}}
  ]

  @spec call :: SchemataSpec.t()
  def call do
    @schemata
  end
end
