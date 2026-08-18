defmodule KantaWeb.Translations.DomainsLiveTest do
  use Kanta.Test.ConnCase, async: false

  alias Kanta.Translations

  describe "mount/3" do
    test "renders the empty state when there are no domains", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/kanta/domains")

      assert html =~ "Domains"
    end

    test "lists the seeded domains", %{conn: conn} do
      {:ok, domain_default} = Translations.create_domain(%{name: "default"})
      {:ok, domain_errors} = Translations.create_domain(%{name: "errors"})

      {:ok, _view, html} = live(conn, "/kanta/domains")

      assert html =~ domain_default.name
      assert html =~ domain_errors.name
    end
  end

  describe "clicking a domain row" do
    test "redirects to the domain edit page", %{conn: conn} do
      {:ok, domain} = Translations.create_domain(%{name: "default"})

      {:ok, view, _html} = live(conn, "/kanta/domains")

      assert {:error, {:live_redirect, %{to: to}}} =
               view
               |> element("[phx-click='edit_domain']", domain.name)
               |> render_click()

      assert to == "/kanta/domains/#{domain.id}"
    end
  end
end
