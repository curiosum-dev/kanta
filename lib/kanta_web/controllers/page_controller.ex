defmodule KantaWeb.PageController do
  use KantaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", conn: conn)
  end
end
