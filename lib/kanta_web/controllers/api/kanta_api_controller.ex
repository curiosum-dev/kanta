defmodule KantaWeb.Api.KantaApiController do
  use KantaWeb, :controller

  def index(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{status: "OK"})
  end
end
