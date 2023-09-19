defmodule KantaWeb.Api.KantaApiController do
  use KantaWeb, :controller

  def index(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{status: "OK"})
  end

  def put_translations(conn, _params) do
    if parse_put_translations_params(conn) do
      conn
      |> put_status(201)
      |> json(%{status: "Created"})
    else
      conn
      |> put_status(400)
      |> json(%{status: "Cannot parse data"})
    end
  end

  defp parse_put_translations_params(conn) do
    case conn.body_params do
      %{
        "plural_translations" => plural_translations,
        "singular_translations" => singular_translations
      } ->
        IO.inspect(plural_translations)
        IO.inspect(singular_translations)
        true

      _ ->
        false
    end
  end
end
