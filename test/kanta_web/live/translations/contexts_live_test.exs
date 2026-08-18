defmodule KantaWeb.Translations.ContextsLiveTest do
  use Kanta.Test.ConnCase, async: false

  alias Kanta.Translations

  describe "mount/3" do
    test "renders the empty state when there are no contexts", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/kanta/contexts")

      assert html =~ "Contexts"
    end

    test "lists the seeded contexts", %{conn: conn} do
      {:ok, context_ui} = Translations.create_context(%{name: "ui"})
      {:ok, context_test} = Translations.create_context(%{name: "test"})

      {:ok, _view, html} = live(conn, "/kanta/contexts")

      assert html =~ context_ui.name
      assert html =~ context_test.name
    end
  end

  describe "clicking a context row" do
    test "redirects to the context edit page", %{conn: conn} do
      {:ok, context} = Translations.create_context(%{name: "ui"})

      {:ok, view, _html} = live(conn, "/kanta/contexts")

      assert {:error, {:live_redirect, %{to: to}}} =
               view
               |> element("[phx-click='edit_context']", context.name)
               |> render_click()

      assert to == "/kanta/contexts/#{context.id}"
    end
  end
end
