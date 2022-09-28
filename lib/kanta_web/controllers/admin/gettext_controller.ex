defmodule KantaWeb.Admin.GettextController do
  use KantaWeb, :controller
  alias Kanta.Gettext

  def index(conn, _params) do
    render(conn, "index.html", translations: Gettext.get_translations())
  end
end
