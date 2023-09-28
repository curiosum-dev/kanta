defmodule Kanta.Translations.Domains.Finders.ListDomains do
  @moduledoc """
  Query module aka Finder responsible for listing gettext domains
  """

  use Kanta.Query,
    module: Kanta.Translations.Domain,
    binding: :domain

  def find(params \\ []) do
    base()
    |> filter_query(params[:filter])
    |> preload_resources(params[:preloads] || [])
    |> paginate(params[:page], params[:per_page])
  end
end
