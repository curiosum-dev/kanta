defmodule Kanta.Translations.ApplicationSources.Finders.ListApplicationSources do
  @moduledoc """
  Query module aka Finder responsible for listing application sources
  """

  use Kanta.Query,
    module: Kanta.Translations.ApplicationSource,
    binding: :domain

  def find(params \\ []) do
    base()
    |> filter_query(params[:filter])
    |> preload_resources(params[:preloads] || [])
    |> paginate(params[:page], params[:per_page])
  end
end
