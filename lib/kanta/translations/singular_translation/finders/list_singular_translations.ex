defmodule Kanta.Translations.SingularTranslations.Finders.ListSingularTranslations do
  @moduledoc """
  Query module aka Finder responsible for listing singular translations
  """

  use Kanta.Query,
    module: Kanta.Translations.SingularTranslation,
    binding: :singular_translation

  def find(params \\ []) do
    base()
    |> filter_query(params[:filter])
    |> search_query(params[:search])
    |> preload_resources(params[:preloads] || [])
    |> paginate(params[:page], params[:per_page])
  end
end
