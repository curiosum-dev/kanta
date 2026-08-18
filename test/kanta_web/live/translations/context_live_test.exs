defmodule KantaWeb.Translations.ContextLiveTest do
  use Kanta.Test.ConnCase, async: false

  alias Kanta.Translations

  describe "mount/3" do
    test "assigns the context when the id is valid", %{conn: conn} do
      {:ok, context} = Translations.create_context(%{name: "ui"})

      {:ok, _view, html} = live(conn, "/kanta/contexts/#{context.id}")

      assert html =~ context.name
    end

    test "redirects to the contexts list when the context does not exist", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/kanta/contexts"}}} =
               live(conn, "/kanta/contexts/999999")
    end

    test "redirects to the contexts list when the id is invalid", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/kanta/contexts"}}} =
               live(conn, "/kanta/contexts/not-an-id")
    end
  end
end
