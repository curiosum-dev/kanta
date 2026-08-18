defmodule Kanta.Test.Endpoint do
  @moduledoc false

  use Phoenix.Endpoint, otp_app: :kanta

  @session_options [
    store: :cookie,
    key: "_kanta_test_key",
    signing_salt: "kanta_test_signing_salt",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  plug Plug.Parsers,
    parsers: [:urlencoded, :json],
    pass: ["*/*"],
    json_decoder: Jason

  plug Plug.Session, @session_options
  plug Kanta.Test.Router
end
