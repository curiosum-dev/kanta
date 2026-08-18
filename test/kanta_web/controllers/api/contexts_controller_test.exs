defmodule KantaWeb.Api.ContextsControllerTest do
  use Kanta.Test.ConnCase, async: false

  alias Kanta.Translations

  describe "GET /kanta-api/contexts" do
    test "returns 401 without a valid bearer token", %{conn: conn} do
      conn = get(conn, "/kanta-api/contexts")

      assert conn.status == 401
    end

    test "lists the seeded contexts", %{conn: conn} do
      {:ok, context} = Translations.create_context(%{name: "ui"})

      conn =
        conn
        |> authed_conn()
        |> get("/kanta-api/contexts")

      response = json_response(conn, 200)
      assert Enum.any?(response["entries"], &(&1["name"] == context.name))
    end
  end

  describe "PUT /kanta-api/contexts/:id" do
    test "upserts contexts from the given entries", %{conn: conn} do
      conn =
        conn
        |> authed_conn()
        |> put("/kanta-api/contexts/bulk", %{
          "entries" => [%{"name" => "from_api"}]
        })

      assert json_response(conn, 200) == %{"status" => "OK"}
      assert {:ok, _context} = Translations.get_context(filter: [name: "from_api"])
    end
  end
end
