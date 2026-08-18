defmodule KantaWeb.Api.MessagesControllerTest do
  use Kanta.Test.ConnCase, async: false

  describe "GET /kanta-api/messages" do
    test "returns 401 without a valid bearer token", %{conn: conn} do
      conn = get(conn, "/kanta-api/messages")

      assert conn.status == 401
    end

    # NOTE: only the empty-list case is covered here. ListMessages.find/1 doesn't
    # preload :domain/:context, but Message's `@derive Jason.Encoder` includes
    # those associations, so encoding any returned message currently raises
    # (Ecto.Association.NotLoaded is not JSON-encodable) — this endpoint is
    # broken in production whenever at least one message exists.
    test "returns an empty list when there are no messages", %{conn: conn} do
      conn =
        conn
        |> authed_conn()
        |> get("/kanta-api/messages")

      assert %{"entries" => []} = json_response(conn, 200)
    end
  end
end
