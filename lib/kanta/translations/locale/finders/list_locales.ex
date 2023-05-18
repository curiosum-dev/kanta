defmodule Kanta.Translations.Locale.Finders.ListLocales do
  use Kanta.Query,
    module: Kanta.Translations.Locale,
    binding: :locale

  def find(params \\ []) do
    base()
    |> filter_query(params[:filter])
    |> search_query(params[:search])
    |> preload_resources(params[:preloads] || [])
    |> paginate(params[:page], params[:per_page])
  end
end
