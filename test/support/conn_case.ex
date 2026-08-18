defmodule Kanta.Test.ConnCase do
  @moduledoc """
  This module defines the setup for tests requiring
  a connection, such as controller and LiveView tests.

  Such tests rely on `Phoenix.ConnTest` and also import
  other functionality to make it easier to build common
  data structures and query the data layer.

  Finally, if the test case interacts with the database,
  it enables the SQL sandbox, so changes done to the
  database are reverted at the end of every test.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Kanta.Test.Repo

      import Plug.Conn
      import Phoenix.ConnTest
      import Phoenix.LiveViewTest
      import Kanta.Test.ConnCase

      @endpoint Kanta.Test.Endpoint
    end
  end

  setup tags do
    Kanta.Test.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Returns the Bearer token accepted by `KantaWeb.APIAuthPlug` in tests,
  matching the `KANTA_SECRET_TOKEN` env var set in `test/test_helper.exs`.
  """
  def api_bearer_token do
    :sha256
    |> :crypto.hash(System.fetch_env!("KANTA_SECRET_TOKEN"))
    |> Base.encode64()
  end

  @doc """
  Builds a `conn` with a valid `Authorization` header for `kanta_api` routes.
  """
  def authed_conn(conn) do
    Plug.Conn.put_req_header(conn, "authorization", "Bearer #{api_bearer_token()}")
  end
end
