defmodule KantaWeb.Api.SingularTranslationsControllerTest do
  use Kanta.Test.ConnCase, async: false

  alias Kanta.Translations

  describe "GET /kanta-api/singular_translations" do
    test "returns 401 without a valid bearer token", %{conn: conn} do
      conn = get(conn, "/kanta-api/singular_translations")

      assert conn.status == 401
    end

    test "lists the seeded singular translations", %{conn: conn} do
      {:ok, locale} =
        Translations.create_locale(%{iso639_code: "en", name: "English", native_name: "English"})

      {:ok, domain} = Translations.create_domain(%{name: "default"})
      {:ok, context} = Translations.create_context(%{name: "ui"})

      {:ok, message} =
        Translations.create_message(%{
          msgid: "Hello world",
          message_type: :singular,
          domain_id: domain.id,
          context_id: context.id
        })

      {:ok, translation} =
        Translations.create_singular_translation(%{
          original_text: "Hello world",
          translated_text: "Bonjour le monde",
          locale_id: locale.id,
          message_id: message.id
        })

      conn =
        conn
        |> authed_conn()
        |> get("/kanta-api/singular_translations")

      response = json_response(conn, 200)

      assert Enum.any?(
               response["entries"],
               &(&1["translated_text"] == translation.translated_text)
             )
    end
  end
end
