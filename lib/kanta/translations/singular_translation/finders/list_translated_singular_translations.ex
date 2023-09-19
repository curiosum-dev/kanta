defmodule Kanta.Translations.SingularTranslations.Finders.ListTranslatedSingularTranslations do
  @moduledoc """
  Query module aka Finder responsible for listing translated singular translations
  """

  use Kanta.Query,
    module: Kanta.Translations.SingularTranslation,
    binding: :singular_translation

  alias Kanta.Repo

  def find do
    base()
    |> translated_query()
    |> Repo.get_repo().all()
  end

  defp translated_query(query) do
    from(st in query,
      where: not is_nil(st.translated_text) and st.translated_text != ""
    )
  end
end
