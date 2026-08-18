defmodule KantaWeb.Translations.DomainLiveTest do
  use Kanta.Test.ConnCase, async: false

  alias Kanta.Translations

  describe "mount/3" do
    test "assigns the domain when the id is valid", %{conn: conn} do
      {:ok, domain} = Translations.create_domain(%{name: "default"})

      {:ok, _view, html} = live(conn, "/kanta/domains/#{domain.id}")

      assert html =~ domain.name
    end

    test "redirects to the domains list when the domain does not exist", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/kanta/domains"}}} =
               live(conn, "/kanta/domains/999999")
    end

    test "redirects to the domains list when the id is invalid", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/kanta/domains"}}} =
               live(conn, "/kanta/domains/not-an-id")
    end
  end
end
