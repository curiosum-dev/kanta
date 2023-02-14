defmodule KantaWeb.Translations.TranslationController do
  use KantaWeb, :controller
  import Phoenix.LiveView.Controller

  alias Kanta.Translations

  alias KantaWeb.Translations.{
    PluralTranslationFormLive,
    SingularTranslationFormLive,
    TranslationsLive
  }

  def index(conn, %{"locale_id" => locale_id}) do
    live_render(conn, TranslationsLive,
      session: %{
        "locale_id" => locale_id
      }
    )
  end

  def show(conn, %{"locale_id" => locale_id, "message_id" => message_id}) do
    message = Translations.get_message(message_id)

    if message.message_type == :singular do
      live_render(conn, SingularTranslationFormLive,
        session: %{
          "locale_id" => locale_id,
          "message_id" => message_id
        }
      )
    else
      live_render(conn, PluralTranslationFormLive,
        session: %{
          "locale_id" => locale_id,
          "message_id" => message_id
        }
      )
    end
  end
end
