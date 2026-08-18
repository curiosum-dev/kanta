defmodule KantaWeb.Api.DomainsControllerTest do
  use Kanta.Test.ConnCase, async: false

  alias Kanta.Translations

  describe "GET /kanta-api/domains" do
    test "returns 401 without a valid bearer token", %{conn: conn} do
      conn = get(conn, "/kanta-api/domains")

      assert conn.status == 401
    end

    test "lists the seeded domains", %{conn: conn} do
      {:ok, domain} = Translations.create_domain(%{name: "default"})

      conn =
        conn
        |> authed_conn()
        |> get("/kanta-api/domains")

      response = json_response(conn, 200)
      assert [entry] = response["entries"]
      assert entry["name"] == domain.name
    end
  end

  describe "PUT /kanta-api/domains/:id" do
    test "upserts domains from the given entries", %{conn: conn} do
      conn =
        conn
        |> authed_conn()
        |> put("/kanta-api/domains/bulk", %{
          "entries" => [%{"name" => "from_api", "description" => "synced from api"}]
        })

      assert json_response(conn, 200) == %{"status" => "OK"}
      assert {:ok, domain} = Translations.get_domain(filter: [name: "from_api"])
      assert domain.description == "synced from api"
    end
  end
end
