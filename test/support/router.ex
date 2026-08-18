defmodule Kanta.Test.Router do
  @moduledoc false

  use Phoenix.Router

  import Phoenix.LiveView.Router
  import KantaWeb.Router

  pipeline :browser do
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/" do
    pipe_through :browser

    kanta_dashboard("/kanta")
  end

  kanta_api("/kanta-api")
end
