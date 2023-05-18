defmodule Kanta.Translations.Contexts do
  alias Kanta.Translations.Context
  alias Kanta.Translations.Contexts.Finders.{GetContext, ListContexts}

  def list_contexts(params \\ []) do
    ListContexts.find(params)
  end

  def get_context(params) do
    GetContext.find(params)
  end

  def create_context(attrs) do
    %Context{}
    |> Context.changeset(attrs)
    |> Kanta.Repo.get_repo().insert()
  end
end
