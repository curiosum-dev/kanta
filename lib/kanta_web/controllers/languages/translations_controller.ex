defmodule KantaWeb.Languages.TranslationsController do
  use KantaWeb, :controller
  alias KantaWeb.TranslationsLive
  import Phoenix.LiveView.Controller

  def show(conn, %{"language" => language}) do
    if language in Kanta.get_languages() do
      live_render(conn, TranslationsLive,
        session: %{
          "language" => language
        }
      )
    else
      redirect(conn)
    end
  end

  def index(conn, _params), do: redirect(conn)

  defp redirect(conn) do
    conn |> redirect(to: Routes.page_path(conn, :index)) |> halt()
  end
end
