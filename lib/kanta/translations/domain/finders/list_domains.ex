defmodule Kanta.Translations.Domains.Finders.ListDomains do
  use Kanta.Query,
    module: Kanta.Translations.Domain,
    binding: :domain

  def find(params \\ []) do
    base()
    |> filter_query(params[:filter])
    |> search_query(params[:search])
    |> preload_resources(params[:preloads] || [])
    |> paginate(params[:page], params[:per_page])
  end
end
