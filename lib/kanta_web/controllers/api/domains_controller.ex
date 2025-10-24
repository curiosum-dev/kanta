defmodule KantaWeb.Api.DomainsController do
  @moduledoc false
  use KantaWeb, :controller

  plug :put_layout, false

  alias Kanta.Translations.Domains.Finders.ListDomains
  alias Kanta.Utils.DatabasePopulator

  def index(conn, params) do
    page = params |> Map.get("page", "1") |> String.to_integer()

    conn
    |> put_status(200)
    |> json(ListDomains.find(page: page))
  end

  def update(conn, %{"entries" => entries}) do
    DatabasePopulator.call("domains", entries)

    conn
    |> put_status(200)
    |> json(%{status: "OK"})
  end
end
