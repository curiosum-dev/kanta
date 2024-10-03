defmodule Kanta.Translations.ApplicationSources do
  @moduledoc """
  ApplicationSources Kanta subcontext
  """

  alias Kanta.Translations.ApplicationSource

  alias Kanta.Translations.ApplicationSources.Finders.{
    GetApplicationSource,
    ListApplicationSources
  }

  def list_application_sources(params \\ []) do
    ListApplicationSources.find(params)
  end

  def get_application_source(params) do
    GetApplicationSource.find(params)
  end

  def create_application_source(attrs, opts \\ []) do
    %ApplicationSource{}
    |> ApplicationSource.changeset(attrs)
    |> Kanta.Repo.get_repo().insert(opts)
  end

  def update_application_source(%ApplicationSource{} = application_source, attrs, opts \\ []) do
    application_source
    |> ApplicationSource.changeset(attrs)
    |> Kanta.Repo.get_repo().update(opts)
  end

  def change_application_source(%ApplicationSource{} = application_source, params \\ %{}) do
    ApplicationSource.changeset(application_source, params)
  end

  def application_sources_empty? do
    %{entries: application_sources, metadata: _application_sources_metadata} =
      list_application_sources(page: 1, per_page: 1)

    Enum.empty?(application_sources)
  end
end
