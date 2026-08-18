defmodule KantaWeb.Api.ApplicationSourcesControllerTest do
  use Kanta.Test.ConnCase, async: false

  alias Kanta.Translations

  describe "GET /kanta-api/applications" do
    test "returns 401 without a valid bearer token", %{conn: conn} do
      conn = get(conn, "/kanta-api/applications")

      assert conn.status == 401
    end

    test "lists the seeded application sources", %{conn: conn} do
      {:ok, source} = Translations.create_application_source(%{name: "my_app"})

      conn =
        conn
        |> authed_conn()
        |> get("/kanta-api/applications")

      response = json_response(conn, 200)
      assert Enum.any?(response["entries"], &(&1["name"] == source.name))
    end
  end

  describe "PUT /kanta-api/applications/:id" do
    test "upserts application sources from the given entries", %{conn: conn} do
      conn =
        conn
        |> authed_conn()
        |> put("/kanta-api/applications/bulk", %{
          "entries" => [%{"name" => "from_api"}]
        })

      assert json_response(conn, 200) == %{"status" => "OK"}
      assert {:ok, _source} = Translations.get_application_source(filter: [name: "from_api"])
    end
  end
end
