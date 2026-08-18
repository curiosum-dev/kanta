defmodule KantaWeb.Api.LocalesControllerTest do
  use Kanta.Test.ConnCase, async: false

  alias Kanta.Translations

  describe "GET /kanta-api/locales" do
    test "returns 401 without a valid bearer token", %{conn: conn} do
      conn = get(conn, "/kanta-api/locales")

      assert conn.status == 401
    end

    test "lists the seeded locales", %{conn: conn} do
      {:ok, locale} =
        Translations.create_locale(%{iso639_code: "en", name: "English", native_name: "English"})

      conn =
        conn
        |> authed_conn()
        |> get("/kanta-api/locales")

      response = json_response(conn, 200)
      assert Enum.any?(response["entries"], &(&1["iso639_code"] == locale.iso639_code))
    end
  end

  describe "PUT /kanta-api/locales/:id" do
    test "upserts locales from the given entries", %{conn: conn} do
      conn =
        conn
        |> authed_conn()
        |> put("/kanta-api/locales/bulk", %{
          "entries" => [
            %{"iso639_code" => "fr", "name" => "French", "native_name" => "Français"}
          ]
        })

      assert json_response(conn, 200) == %{"status" => "OK"}
      assert {:ok, _locale} = Translations.get_locale(filter: [iso639_code: "fr"])
    end
  end
end
