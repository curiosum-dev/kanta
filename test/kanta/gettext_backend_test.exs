defmodule Kanta.GettextBackendTest do
  use ExUnit.Case, async: false

  # Simple Mock Adapter for Gettext API testing
  defmodule MockAdapter do
    @behaviour Kanta.Backend.Source

    @impl true
    def known_locales(_backend), do: ["en", "fr", "de"]

    @impl true
    def validate_opts(opts) do
      opts
    end

    @impl true
    def lookup_lgettext(_backend, "en", "default", nil, "Hello"), do: {:ok, "Hello"}
    def lookup_lgettext(_backend, "fr", "default", nil, "Hello"), do: {:ok, "Bonjour"}
    def lookup_lgettext(_backend, "en", "default", nil, "World"), do: {:ok, "World"}
    def lookup_lgettext(_backend, "fr", "default", nil, "World"), do: {:ok, "Monde"}
    def lookup_lgettext(_backend, "en", "errors", nil, "Not found"), do: {:ok, "Not found"}
    def lookup_lgettext(_backend, "fr", "errors", nil, "Not found"), do: {:ok, "Pas trouvé"}

    def lookup_lgettext(_backend, "en", "default", nil, "Hello %{name}"),
      do: {:ok, "Hello %{name}"}

    def lookup_lgettext(_backend, "fr", "default", nil, "Hello %{name}"),
      do: {:ok, "Bonjour %{name}"}

    def lookup_lgettext(_backend, "en", "default", "verb", "File"), do: {:ok, "File (verb)"}
    def lookup_lgettext(_backend, "fr", "default", "verb", "File"), do: {:ok, "Classer"}
    def lookup_lgettext(_backend, _, _, _, _), do: {:error, :not_found}

    @impl true
    def lookup_lngettext(_backend, "en", "default", nil, "Item", "Items", 0), do: {:ok, "Item"}

    def lookup_lngettext(_backend, "en", "default", nil, "Item", "Items", 1),
      do: {:ok, "%{count} Items"}

    def lookup_lngettext(_backend, "fr", "default", nil, "Item", "Items", 0), do: {:ok, "Objet"}

    def lookup_lngettext(_backend, "fr", "default", nil, "Item", "Items", 1),
      do: {:ok, "%{count} Objets"}

    def lookup_lngettext(_backend, "en", "errors", nil, "Error", "Errors", 0), do: {:ok, "Error"}

    def lookup_lngettext(_backend, "en", "errors", nil, "Error", "Errors", 1),
      do: {:ok, "%{count} Errors"}

    def lookup_lngettext(_backend, "fr", "errors", nil, "Error", "Errors", 0), do: {:ok, "Erreur"}

    def lookup_lngettext(_backend, "fr", "errors", nil, "Error", "Errors", 1),
      do: {:ok, "%{count} Erreurs"}

    def lookup_lngettext(_backend, "en", "default", "files", "File", "Files", 0),
      do: {:ok, "1 File (cx)"}

    def lookup_lngettext(_backend, "en", "default", "files", "File", "Files", 1),
      do: {:ok, "%{count} Files (cx)"}

    def lookup_lngettext(_backend, _, _, _, _, _, _), do: {:error, :not_found}
  end

  # The Gettext Backend module using Kanta
  defmodule MyApp.Gettext do
    use Kanta.Backend,
      otp_app: :kanta_gettext_test,
      source: Kanta.GettextBackendTest.MockAdapter
  end

  # A module using the Gettext API
  defmodule MyApp.Translator do
    use Gettext, backend: Kanta.GettextBackendTest.MyApp.Gettext
    def greet_macro(name), do: gettext("Hello %{name}", name: name)
  end

  # No more setup block needed - we'll use with_locale in each test!

  describe "Gettext API integration with Kanta.Backend" do
    test "Gettext.gettext/3 translates based on locale" do
      Gettext.with_locale(MyApp.Gettext, "en", fn ->
        # Default locale (en)
        assert Gettext.gettext(MyApp.Gettext, "Hello") == "Hello"

        # Change locale
        Gettext.put_locale(MyApp.Gettext, "fr")
        assert Gettext.gettext(MyApp.Gettext, "Hello") == "Bonjour"

        # Unknown locale falls back to default locale
        Gettext.put_locale(MyApp.Gettext, "xx")
        assert Gettext.gettext(MyApp.Gettext, "Hello") == "Hello"

        # Missing translation falls back to msgid
        Gettext.put_locale(MyApp.Gettext, "fr")
        assert Gettext.gettext(MyApp.Gettext, "Missing") == "Missing"
      end)
    end

    test "Gettext.gettext/3 handles interpolation" do
      Gettext.with_locale(MyApp.Gettext, "fr", fn ->
        assert Gettext.gettext(MyApp.Gettext, "Hello %{name}", name: "Alice") == "Bonjour Alice"
      end)
    end

    test "Gettext.dgettext/4 translates based on domain and locale" do
      Gettext.with_locale(MyApp.Gettext, "fr", fn ->
        assert Gettext.dgettext(MyApp.Gettext, "default", "World") == "Monde"
        assert Gettext.dgettext(MyApp.Gettext, "errors", "Not found") == "Pas trouvé"
        assert Gettext.dgettext(MyApp.Gettext, "unknown", "Not found") == "Not found"
      end)
    end

    test "Gettext.pgettext/4 translates based on context" do
      Gettext.with_locale(MyApp.Gettext, "en", fn ->
        assert Gettext.pgettext(MyApp.Gettext, "verb", "File") == "File (verb)"

        Gettext.put_locale(MyApp.Gettext, "fr")
        assert Gettext.pgettext(MyApp.Gettext, "verb", "File") == "Classer"
        assert Gettext.pgettext(MyApp.Gettext, "noun", "File") == "File"
      end)
    end

    test "Gettext.ngettext/5 handles plurals based on locale" do
      Gettext.with_locale(MyApp.Gettext, "en", fn ->
        assert Gettext.ngettext(MyApp.Gettext, "Item", "Items", 1) == "Item"
        assert Gettext.ngettext(MyApp.Gettext, "Item", "Items", 2) == "2 Items"
        assert Gettext.ngettext(MyApp.Gettext, "Item", "Items", 0) == "0 Items"

        Gettext.put_locale(MyApp.Gettext, "fr")
        assert Gettext.ngettext(MyApp.Gettext, "Item", "Items", 1) == "Objet"
        assert Gettext.ngettext(MyApp.Gettext, "Item", "Items", 0) == "Objet"
        assert Gettext.ngettext(MyApp.Gettext, "Item", "Items", 2) == "2 Objets"

        Gettext.put_locale(MyApp.Gettext, "de")
        assert Gettext.ngettext(MyApp.Gettext, "Item", "Items", 1) == "Item"
        assert Gettext.ngettext(MyApp.Gettext, "Item", "Items", 2) == "Items"
      end)
    end

    test "Gettext.dngettext/6 handles plurals based on domain and locale" do
      Gettext.with_locale(MyApp.Gettext, "fr", fn ->
        assert Gettext.dngettext(MyApp.Gettext, "default", "Item", "Items", 2) == "2 Objets"
        assert Gettext.dngettext(MyApp.Gettext, "errors", "Error", "Errors", 1) == "Erreur"
        assert Gettext.dngettext(MyApp.Gettext, "errors", "Error", "Errors", 5) == "5 Erreurs"
        assert Gettext.dngettext(MyApp.Gettext, "unknown", "Error", "Errors", 1) == "Error"
        assert Gettext.dngettext(MyApp.Gettext, "unknown", "Error", "Errors", 5) == "Errors"
      end)
    end

    test "Gettext.pngettext/6 handles plurals based on context" do
      Gettext.with_locale(MyApp.Gettext, "en", fn ->
        assert Gettext.pngettext(MyApp.Gettext, "files", "File", "Files", 1, %{}) == "1 File (cx)"

        assert Gettext.pngettext(MyApp.Gettext, "files", "File", "Files", 3, %{}) ==
                 "3 Files (cx)"

        assert Gettext.pngettext(MyApp.Gettext, "other", "File", "Files", 1, %{}) == "File"
        assert Gettext.pngettext(MyApp.Gettext, "other", "File", "Files", 3, %{}) == "Files"
      end)
    end
  end
end
