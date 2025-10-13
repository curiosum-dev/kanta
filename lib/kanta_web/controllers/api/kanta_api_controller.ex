defmodule KantaWeb.Api.KantaApiController do
  use KantaWeb, :controller

  plug :put_layout, false

  def index(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{status: "OK"})
  end
end
