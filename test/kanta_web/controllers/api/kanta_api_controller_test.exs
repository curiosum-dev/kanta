defmodule KantaWeb.Api.KantaApiControllerTest do
  use Kanta.Test.ConnCase, async: false

  describe "GET /kanta-api" do
    test "returns 401 without a valid bearer token", %{conn: conn} do
      conn = get(conn, "/kanta-api")

      assert conn.status == 401
    end

    test "returns 200 with a valid bearer token", %{conn: conn} do
      conn =
        conn
        |> authed_conn()
        |> get("/kanta-api")

      assert json_response(conn, 200) == %{"status" => "OK"}
    end
  end
end
