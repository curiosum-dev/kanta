defmodule KantaWeb.Translations.TranslationsLiveTest do
  use Kanta.Test.ConnCase, async: false

  alias Kanta.Translations

  describe "mount/3" do
    test "redirects to the locales list when the locale does not exist", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/kanta/locales"}}} =
               live(conn, "/kanta/locales/999999/translations")
    end

    test "lists the messages for the given locale", %{conn: conn} do
      {:ok, locale} =
        Translations.create_locale(%{iso639_code: "en", name: "English", native_name: "English"})

      {:ok, domain} = Translations.create_domain(%{name: "default"})
      {:ok, context} = Translations.create_context(%{name: "greetings"})

      {:ok, message} =
        Translations.create_message(%{
          msgid: "Hello world",
          message_type: :singular,
          domain_id: domain.id,
          context_id: context.id
        })

      {:ok, _view, html} = live(conn, "/kanta/locales/#{locale.id}/translations")

      assert html =~ message.msgid
    end
  end
end
