defmodule KantaWeb.Api.ApplicationSourcesController do
  @moduledoc false
  use KantaWeb, :controller

  alias Kanta.Translations
  alias Kanta.Utils.DatabasePopulator

  def index(conn, params) do
    page = params |> Map.get("page", "1") |> String.to_integer()

    conn
    |> put_status(200)
    |> json(Translations.list_application_sources(page: page))
  end

  def update(conn, %{"entries" => entries}) do
    DatabasePopulator.call("application_sources", entries)

    conn
    |> put_status(200)
    |> json(%{status: "OK"})
  end
end
