defmodule Kanta.Translations.PluralTranslations.Finders.ListTranslatedPluralTranslations do
  @moduledoc """
  Query module aka Finder responsible for listing translated plural translations
  """

  use Kanta.Query,
    module: Kanta.Translations.PluralTranslation,
    binding: :plural_translation

  alias Kanta.Repo

  def find do
    base()
    |> translated_query()
    |> Repo.get_repo().all()
  end

  defp translated_query(query) do
    from(pt in query,
      where: not is_nil(pt.translated_text) and pt.translated_text != ""
    )
  end
end
