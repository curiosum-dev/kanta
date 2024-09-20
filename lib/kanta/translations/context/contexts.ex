defmodule Kanta.Translations.Contexts do
  @moduledoc """
  Gettext Contexts Kanta subcontext
  """

  alias Kanta.Translations.Context
  alias Kanta.Translations.Contexts.Finders.{GetContext, ListAllContexts, ListContexts}

  def list_contexts(params \\ []) do
    ListContexts.find(params)
  end

  def list_all_contexts(params \\ []) do
    ListAllContexts.find(params)
  end

  def get_context(params) do
    GetContext.find(params)
  end

  def create_context(attrs, opts \\ []) do
    %Context{}
    |> Context.changeset(attrs)
    |> Kanta.Repo.get_repo().insert(opts)
  end
end
