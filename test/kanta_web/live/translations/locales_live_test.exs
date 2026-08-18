defmodule KantaWeb.Translations.LocalesLiveTest do
  use Kanta.Test.ConnCase, async: false

  alias Kanta.Translations

  describe "mount/3" do
    test "renders the empty state when there are no locales", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/kanta/locales")

      assert html =~ "Locales"
      refute html =~ "English"
    end

    test "lists the seeded locales", %{conn: conn} do
      {:ok, locale_en} =
        Translations.create_locale(%{
          iso639_code: "en",
          name: "English",
          native_name: "English",
          colors: ["#123456"]
        })

      {:ok, locale_es} =
        Translations.create_locale(%{
          iso639_code: "es",
          name: "Spanish",
          native_name: "Español",
          colors: ["#654321"]
        })

      {:ok, _view, html} = live(conn, "/kanta/locales")

      assert html =~ locale_en.name
      assert html =~ locale_es.name
    end
  end

  describe "generate_locale_gradient/1" do
    alias KantaWeb.Translations.LocalesLive

    test "returns a flat background for a single color" do
      css = LocalesLive.generate_locale_gradient(%{colors: ["#123456"]})

      assert css == "background: #123456;"
    end

    test "returns a two-color gradient" do
      css = LocalesLive.generate_locale_gradient(%{colors: ["#111111", "#222222"]})

      assert css =~ "linear-gradient"
      assert css =~ "#111111"
      assert css =~ "#222222"
    end

    test "returns a three-color gradient" do
      css = LocalesLive.generate_locale_gradient(%{colors: ["#111111", "#222222", "#333333"]})

      assert css =~ "linear-gradient"
      assert css =~ "#111111"
      assert css =~ "#222222"
      assert css =~ "#333333"
    end
  end
end
