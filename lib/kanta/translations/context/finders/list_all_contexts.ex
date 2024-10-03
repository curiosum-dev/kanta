defmodule Kanta.Translations.Contexts.Finders.ListAllContexts do
  @moduledoc """
  Query module aka Finder responsible for listing all gettext contexts
  """

  use Kanta.Query,
    module: Kanta.Translations.Context,
    binding: :context

  def find(params \\ []) do
    repo = Kanta.Repo.get_repo()

    base()
    |> filter_query(params[:filter])
    |> preload_resources(params[:preloads] || [])
    |> repo.all()
  end
end
