defmodule KantaWeb.Translations.ApplicationSourcesLiveTest do
  use Kanta.Test.ConnCase, async: false

  alias Kanta.Translations

  describe "mount/3" do
    test "renders the empty state when there are no application sources", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/kanta/application_sources")

      assert html =~ "Application"
    end

    test "lists the seeded application sources", %{conn: conn} do
      {:ok, source} = Translations.create_application_source(%{name: "my_app"})

      {:ok, _view, html} = live(conn, "/kanta/application_sources")

      assert html =~ source.name
    end
  end

  describe "clicking an application source row" do
    test "redirects to the application source edit page", %{conn: conn} do
      {:ok, source} = Translations.create_application_source(%{name: "my_app"})

      {:ok, view, _html} = live(conn, "/kanta/application_sources")

      assert {:error, {:live_redirect, %{to: to}}} =
               view
               |> element("[phx-click='edit_application_source']", source.name)
               |> render_click()

      assert to == "/kanta/application_sources/#{source.id}"
    end
  end
end
