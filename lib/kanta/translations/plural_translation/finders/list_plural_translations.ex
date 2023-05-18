defmodule Kanta.Translations.PluralTranslations.Finders.ListPluralTranslations do
  use Kanta.Query,
    module: Kanta.Translations.PluralTranslation,
    binding: :plural_translation

  def find(params \\ []) do
    base()
    |> filter_query(params[:filter])
    |> search_query(params[:search])
    |> preload_resources(params[:preloads] || [])
    |> paginate(params[:page], params[:per_page])
  end
end
