defmodule Kanta.Translations.Contexts.Finders.ListContexts do
  use Kanta.Query,
    module: Kanta.Translations.Context,
    binding: :context

  def find(params \\ []) do
    base()
    |> filter_query(params[:filter])
    |> search_query(params[:search])
    |> preload_resources(params[:preloads] || [])
    |> paginate(params[:page], params[:per_page])
  end
end
