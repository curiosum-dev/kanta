defmodule KantaWeb.Api.LocalesController do
  @moduledoc false
  use KantaWeb, :controller

  plug :put_layout, false

  alias Kanta.Translations.Locale.Finders.ListLocales
  alias Kanta.Utils.DatabasePopulator

  def index(conn, params) do
    page = params |> Map.get("page", "1") |> String.to_integer()

    conn
    |> put_status(200)
    |> json(ListLocales.find(page: page))
  end

  def update(conn, %{"entries" => entries}) do
    DatabasePopulator.call("locales", entries)

    conn
    |> put_status(200)
    |> json(%{status: "OK"})
  end
end
