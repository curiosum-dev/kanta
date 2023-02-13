defmodule KantaWeb.Translations.LocaleController do
  use KantaWeb, :controller
  import Phoenix.LiveView.Controller

  alias KantaWeb.Translations.LocalesLive

  def index(conn, _params) do
    live_render(conn, LocalesLive, session: %{})
  end
end
