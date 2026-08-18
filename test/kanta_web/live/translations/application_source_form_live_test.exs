defmodule KantaWeb.Translations.ApplicationSourceFormLiveTest do
  use Kanta.Test.ConnCase, async: false

  alias Kanta.Translations

  describe "mount/3 - new application source" do
    test "renders an empty creation form", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/kanta/application_sources/new")

      assert html =~ "Creating application source"
    end

    test "creates the application source and redirects on valid submit", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/kanta/application_sources/new")

      assert {:error, {:live_redirect, %{to: "/kanta/application_sources"}}} =
               view
               |> form("form", application_source: %{"name" => "my_app"})
               |> render_submit()

      assert {:ok, _source} = Translations.get_application_source(filter: [name: "my_app"])
    end

    test "shows a validation error and does not redirect on invalid submit", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/kanta/application_sources/new")

      html =
        view
        |> form("form", application_source: %{"name" => ""})
        |> render_change()

      assert html =~ "can&#39;t be blank"
    end
  end

  describe "mount/3 - editing an application source" do
    test "renders the form pre-filled with the existing name", %{conn: conn} do
      {:ok, source} = Translations.create_application_source(%{name: "my_app"})

      {:ok, _view, html} = live(conn, "/kanta/application_sources/#{source.id}")

      assert html =~ "Updating application source"
      assert html =~ "my_app"
    end

    test "updates the application source and redirects on valid submit", %{conn: conn} do
      {:ok, source} = Translations.create_application_source(%{name: "my_app"})

      {:ok, view, _html} = live(conn, "/kanta/application_sources/#{source.id}")

      assert {:error, {:live_redirect, %{to: "/kanta/application_sources"}}} =
               view
               |> form("form", application_source: %{"name" => "renamed_app"})
               |> render_submit()

      assert {:ok, updated} = Translations.get_application_source(filter: [id: source.id])
      assert updated.name == "renamed_app"
    end

    test "redirects to the list when the application source does not exist", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/kanta/application_sources"}}} =
               live(conn, "/kanta/application_sources/999999")
    end
  end
end
