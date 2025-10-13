defmodule KantaWeb.Api.ContextsController do
  @moduledoc false
  use KantaWeb, :controller

  plug :put_layout, false

  alias Kanta.Translations.Contexts.Finders.ListContexts
  alias Kanta.Utils.DatabasePopulator

  def index(conn, params) do
    page = params |> Map.get("page", "1") |> String.to_integer()

    conn
    |> put_status(200)
    |> json(ListContexts.find(page: page))
  end

  def update(conn, %{"entries" => entries}) do
    DatabasePopulator.call("contexts", entries)

    conn
    |> put_status(200)
    |> json(%{status: "OK"})
  end
end
