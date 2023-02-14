defmodule KantaWeb.Translations.TranslationController do
  use KantaWeb, :controller
  import Phoenix.LiveView.Controller

  alias KantaWeb.Translations.{TranslationFormLive, TranslationsLive}

  def index(conn, %{"locale_id" => locale_id}) do
    live_render(conn, TranslationsLive,
      session: %{
        "locale_id" => locale_id
      }
    )
  end

  def show(conn, %{"locale_id" => locale_id, "message_id" => message_id}) do
    live_render(conn, TranslationFormLive,
      session: %{
        "locale_id" => locale_id,
        "message_id" => message_id
      }
    )
  end

  defp redirect(conn) do
    conn |> redirect(to: Routes.page_path(conn, :index)) |> halt()
  end
end
