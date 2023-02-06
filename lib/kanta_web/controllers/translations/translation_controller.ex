defmodule KantaWeb.Translations.TranslationController do
  use KantaWeb, :controller
  import Phoenix.LiveView.Controller

  alias KantaWeb.Translations.TranslationsLive

  def index(conn, _params), do: redirect(conn)

  def show(conn, %{"language" => language}) do
    # if language in Kanta.get_languages() do
    live_render(conn, TranslationsLive,
      session: %{
        "language" => language
      }
    )

    # else
    # redirect(conn)
    # end
  end

  defp redirect(conn) do
    conn |> redirect(to: Routes.page_path(conn, :index)) |> halt()
  end
end
