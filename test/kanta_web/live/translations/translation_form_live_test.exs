defmodule KantaWeb.Translations.TranslationFormLiveTest do
  use Kanta.Test.ConnCase, async: false

  alias Kanta.Translations

  describe "mount/3 - singular message" do
    setup do
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

      %{locale: locale, message: message}
    end

    test "renders the singular translation form", %{conn: conn, locale: locale, message: message} do
      {:ok, _view, html} =
        live(conn, "/kanta/locales/#{locale.id}/translations/#{message.id}")

      assert html =~ message.msgid
      assert html =~ locale.native_name
    end

    test "redirects when the locale does not exist", %{conn: conn, message: message} do
      assert {:error, {:redirect, %{to: "/kanta/locales/999999/translations"}}} =
               live(conn, "/kanta/locales/999999/translations/#{message.id}")
    end

    test "redirects when the message does not exist", %{conn: conn, locale: locale} do
      assert {:error, {:redirect, %{to: to}}} =
               live(conn, "/kanta/locales/#{locale.id}/translations/999999")

      assert to == "/kanta/locales/#{locale.id}/translations"
    end
  end

  describe "mount/3 - plural message" do
    test "renders the plural translation form", %{conn: conn} do
      {:ok, locale} =
        Translations.create_locale(%{
          iso639_code: "en",
          name: "English",
          native_name: "English",
          plurals_header: "nplurals=2; plural=(n != 1);"
        })

      {:ok, domain} = Translations.create_domain(%{name: "default"})
      {:ok, context} = Translations.create_context(%{name: "greetings"})

      {:ok, message} =
        Translations.create_message(%{
          msgid: "%{count} item",
          message_type: :plural,
          domain_id: domain.id,
          context_id: context.id
        })

      {:ok, _view, html} =
        live(conn, "/kanta/locales/#{locale.id}/translations/#{message.id}")

      assert html =~ message.msgid
    end
  end
end
