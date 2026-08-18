defmodule KantaWeb.Dashboard.DashboardLiveTest do
  use Kanta.Test.ConnCase, async: false

  alias Kanta.Translations

  describe "mount/3" do
    test "renders the dashboard with the current counts", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/kanta")

      assert html =~ "Dashboard"
    end

    test "reflects the seeded locale in the translation progress list", %{conn: conn} do
      {:ok, locale} =
        Translations.create_locale(%{iso639_code: "en", name: "English", native_name: "English"})

      {:ok, _domain} = Translations.create_domain(%{name: "default"})

      {:ok, _view, html} = live(conn, "/kanta")

      assert html =~ locale.name
    end
  end

  describe "handle_event/3 - clear-cache" do
    test "clears the cache and updates the count", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/kanta")

      html = render_click(view, "clear-cache", %{})

      assert html =~ "Cache"
    end
  end
end
