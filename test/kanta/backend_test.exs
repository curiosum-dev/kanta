defmodule Kanta.BackendTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureLog

  # --- Call Counter Agent ---
  defmodule CallCounterAgent do
    use Agent

    def start_link(_opts) do
      Agent.start_link(fn -> 0 end, name: __MODULE__)
    end

    def increment do
      Agent.update(__MODULE__, &(&1 + 1))
    end

    def get_count do
      Agent.get(__MODULE__, & &1)
    end

    def reset do
      Agent.update(__MODULE__, fn _ -> 0 end)
    end
  end

  # --- Mock adapter with call counting ---
  defmodule MockSource do
    @behaviour Kanta.Backend.Source

    defp count_and_return(result) do
      CallCounterAgent.increment()
      result
    end

    def validate_opts(opts), do: opts
    def known_locales(_backend), do: ["en", "fr", "es", "pl"]

    def lookup_lgettext(_backend, "en", "default", nil, "Hello"),
      do: count_and_return({:ok, "Hello"})

    def lookup_lgettext(_backend, "fr", "default", nil, "Hello"),
      do: count_and_return({:ok, "Bonjour"})

    def lookup_lgettext(_backend, "es", "default", nil, "Hello"),
      do: count_and_return({:ok, "Hola"})

    def lookup_lgettext(_backend, "en", "default", nil, "Hello %{name}"),
      do: count_and_return({:ok, "Hello %{name}"})

    def lookup_lgettext(_backend, "fr", "default", nil, "Hello %{name}"),
      do: count_and_return({:ok, "Bonjour %{name}"})

    def lookup_lgettext(_backend, "en", "errors", nil, "Not found"),
      do: count_and_return({:ok, "Not found"})

    def lookup_lgettext(_backend, "fr", "errors", nil, "Not found"),
      do: count_and_return({:ok, "Pas trouvé"})

    def lookup_lgettext(_backend, _, _, _, _), do: count_and_return({:error, :not_found})

    # Plural Lookups (index based)
    # n=1
    def lookup_lngettext(_backend, "en", "default", nil, "One item", "%{count} items", 0),
      do: count_and_return({:ok, "One item"})

    # n!=1
    def lookup_lngettext(_backend, "en", "default", nil, "One item", "%{count} items", 1),
      do: count_and_return({:ok, "%{count} items"})

    # n=0,1
    def lookup_lngettext(_backend, "fr", "default", nil, "One item", "%{count} items", 0),
      do: count_and_return({:ok, "Un objet"})

    # n>1
    def lookup_lngettext(_backend, "fr", "default", nil, "One item", "%{count} items", 1),
      do: count_and_return({:ok, "%{count} objets"})

    # n=1
    def lookup_lngettext(_backend, "es", "default", nil, "One item", "%{count} items", 0),
      do: count_and_return({:ok, "Un artículo"})

    # n!=1
    def lookup_lngettext(_backend, "es", "default", nil, "One item", "%{count} items", 1),
      do: count_and_return({:ok, "%{count} artículos"})

    # n=1
    def lookup_lngettext(_backend, "pl", "default", nil, "One item", "%{count} items", 0),
      do: count_and_return({:ok, "Jeden przedmiot"})

    # n=2,3,4 mod 10, !12,13,14
    def lookup_lngettext(_backend, "pl", "default", nil, "One item", "%{count} items", 1),
      do: count_and_return({:ok, "%{count} przedmioty"})

    # other
    def lookup_lngettext(_backend, "pl", "default", nil, "One item", "%{count} items", 2),
      do: count_and_return({:ok, "%{count} przedmiotów"})

    def lookup_lngettext(_backend, _, _, _, _, _, _), do: count_and_return({:error, :not_found})
  end

  # --- Test Gettext Modules ---
  defmodule TestGettextWithCache do
    use Kanta.Backend,
      otp_app: :kanta_test,
      source: Kanta.BackendTest.MockSource,
      cache: Kanta.Cache
  end

  defmodule TestGettextWithoutCache do
    use Kanta.Backend,
      otp_app: :kanta_test,
      source: Kanta.BackendTest.MockSource

    # Cache is implicitly disabled (defaults to nil)
  end

  defmodule DefaultAdapterGettext do
    use Kanta.Backend, otp_app: :kanta_test, source_opts: [repo: nil]
  end

  # --- Setup ---
  # Start the Agent once for the entire test module
  setup_all do
    {:ok, _pid} = CallCounterAgent.start_link([])
    # Return an :on_exit callback to stop the agent after all tests
    on_exit(fn -> Agent.stop(CallCounterAgent) end)
    :ok
  end

  setup do
    CallCounterAgent.reset()
    Kanta.Cache.delete_all()
    :ok
  end

  # --- Basic Config Tests ---
  describe "backend configuration" do
    test "returns correct configuration values (with cache)" do
      assert TestGettextWithCache.__gettext__(:otp_app) == :kanta_test
      assert TestGettextWithCache.__gettext__(:default_locale) == "en"
      assert TestGettextWithCache.__gettext__(:default_domain) == "default"
      assert is_binary(TestGettextWithCache.__gettext__(:priv))
      assert TestGettextWithCache.__gettext__(:known_locales) == ["en", "fr", "es", "pl"]
    end

    test "returns correct configuration values (without cache)" do
      assert TestGettextWithoutCache.__gettext__(:otp_app) == :kanta_test
      assert TestGettextWithoutCache.__gettext__(:default_locale) == "en"
      assert TestGettextWithoutCache.__gettext__(:default_domain) == "default"
      assert is_binary(TestGettextWithoutCache.__gettext__(:priv))
      assert TestGettextWithoutCache.__gettext__(:known_locales) == ["en", "fr", "es", "pl"]
    end

    test "uses the specified adapter" do
      assert TestGettextWithCache.__gettext__(:known_locales) == ["en", "fr", "es", "pl"]
      assert TestGettextWithoutCache.__gettext__(:known_locales) == ["en", "fr", "es", "pl"]
    end

    test "uses default adapter when none specified" do
      assert DefaultAdapterGettext.__gettext__(:otp_app) == :kanta_test
    end
  end

  # --- Core Translation Logic Tests (Using WithCache module for coverage) ---
  describe "gettext translation (core logic)" do
    test "translates simple strings" do
      assert TestGettextWithCache.lgettext("en", "default", nil, "Hello", %{}) == {:ok, "Hello"}
      assert TestGettextWithCache.lgettext("fr", "default", nil, "Hello", %{}) == {:ok, "Bonjour"}
      assert TestGettextWithCache.lgettext("es", "default", nil, "Hello", %{}) == {:ok, "Hola"}
    end

    test "handles interpolation" do
      assert TestGettextWithCache.lgettext("en", "default", nil, "Hello %{name}", %{name: "John"}) ==
               {:ok, "Hello John"}

      assert TestGettextWithCache.lgettext("fr", "default", nil, "Hello %{name}", %{name: "Jean"}) ==
               {:ok, "Bonjour Jean"}
    end

    test "uses different domains" do
      assert TestGettextWithCache.lgettext("en", "errors", nil, "Not found", %{}) ==
               {:ok, "Not found"}

      assert TestGettextWithCache.lgettext("fr", "errors", nil, "Not found", %{}) ==
               {:ok, "Pas trouvé"}
    end

    test "returns default translation when not found" do
      assert TestGettextWithCache.lgettext("en", "default", nil, "Missing translation", %{}) ==
               {:default, "Missing translation"}

      assert TestGettextWithCache.lgettext("unknown", "default", nil, "Hello", %{}) ==
               {:default, "Hello"}
    end
  end

  describe "plural translations (core logic)" do
    test "handles singular forms (n=1)" do
      assert TestGettextWithCache.lngettext(
               "en",
               "default",
               nil,
               "One item",
               "%{count} items",
               1,
               %{}
             ) ==
               {:ok, "One item"}

      assert TestGettextWithCache.lngettext(
               "fr",
               "default",
               nil,
               "One item",
               "%{count} items",
               1,
               %{}
             ) ==
               {:ok, "Un objet"}
    end

    test "handles plural forms" do
      assert TestGettextWithCache.lngettext(
               "en",
               "default",
               nil,
               "One item",
               "%{count} items",
               0,
               %{}
             ) ==
               {:ok, "0 items"}

      assert TestGettextWithCache.lngettext(
               "en",
               "default",
               nil,
               "One item",
               "%{count} items",
               5,
               %{}
             ) ==
               {:ok, "5 items"}

      # French index 0 covers n=0
      assert TestGettextWithCache.lngettext(
               "fr",
               "default",
               nil,
               "One item",
               "%{count} items",
               0,
               %{}
             ) ==
               {:ok, "Un objet"}

      assert TestGettextWithCache.lngettext(
               "fr",
               "default",
               nil,
               "One item",
               "%{count} items",
               5,
               %{}
             ) ==
               {:ok, "5 objets"}
    end

    test "falls back to default when translation not found" do
      assert TestGettextWithCache.lngettext(
               "en",
               "unknown",
               nil,
               "One thing",
               "%{count} things",
               1,
               %{}
             ) ==
               {:default, "One thing"}

      assert TestGettextWithCache.lngettext(
               "en",
               "unknown",
               nil,
               "One thing",
               "%{count} things",
               2,
               %{}
             ) ==
               {:default, "2 things"}
    end
  end

  describe "plural forms handling (core logic)" do
    test "uses correct plural form for English" do
      # n=1 -> idx 0
      assert TestGettextWithCache.lngettext(
               "en",
               "default",
               nil,
               "One item",
               "%{count} items",
               1,
               %{}
             ) == {:ok, "One item"}

      # n=0 -> idx 1
      assert TestGettextWithCache.lngettext(
               "en",
               "default",
               nil,
               "One item",
               "%{count} items",
               0,
               %{}
             ) == {:ok, "0 items"}

      # n=2 -> idx 1
      assert TestGettextWithCache.lngettext(
               "en",
               "default",
               nil,
               "One item",
               "%{count} items",
               2,
               %{}
             ) == {:ok, "2 items"}

      # n=5 -> idx 1
      assert TestGettextWithCache.lngettext(
               "en",
               "default",
               nil,
               "One item",
               "%{count} items",
               5,
               %{}
             ) == {:ok, "5 items"}
    end

    test "uses correct plural form for French" do
      # n=1 -> idx 0
      assert TestGettextWithCache.lngettext(
               "fr",
               "default",
               nil,
               "One item",
               "%{count} items",
               1,
               %{}
             ) == {:ok, "Un objet"}

      # n=0 -> idx 0
      assert TestGettextWithCache.lngettext(
               "fr",
               "default",
               nil,
               "One item",
               "%{count} items",
               0,
               %{}
             ) == {:ok, "Un objet"}

      # n=2 -> idx 1
      assert TestGettextWithCache.lngettext(
               "fr",
               "default",
               nil,
               "One item",
               "%{count} items",
               2,
               %{}
             ) == {:ok, "2 objets"}
    end

    test "uses correct plural form for Spanish" do
      # n=1 -> idx 0
      assert TestGettextWithCache.lngettext(
               "es",
               "default",
               nil,
               "One item",
               "%{count} items",
               1,
               %{}
             ) == {:ok, "Un artículo"}

      # n=2 -> idx 1
      assert TestGettextWithCache.lngettext(
               "es",
               "default",
               nil,
               "One item",
               "%{count} items",
               2,
               %{}
             ) == {:ok, "2 artículos"}
    end

    test "handles languages with complex plural rules (Polish)" do
      # n=1 -> idx 0
      assert TestGettextWithCache.lngettext(
               "pl",
               "default",
               nil,
               "One item",
               "%{count} items",
               1,
               %{}
             ) == {:ok, "Jeden przedmiot"}

      # n=2 -> idx 1
      assert TestGettextWithCache.lngettext(
               "pl",
               "default",
               nil,
               "One item",
               "%{count} items",
               2,
               %{}
             ) == {:ok, "2 przedmioty"}

      # n=5 -> idx 2
      assert TestGettextWithCache.lngettext(
               "pl",
               "default",
               nil,
               "One item",
               "%{count} items",
               5,
               %{}
             ) == {:ok, "5 przedmiotów"}

      # n=12 -> idx 2
      assert TestGettextWithCache.lngettext(
               "pl",
               "default",
               nil,
               "One item",
               "%{count} items",
               12,
               %{}
             ) == {:ok, "12 przedmiotów"}

      # n=22 -> idx 1
      assert TestGettextWithCache.lngettext(
               "pl",
               "default",
               nil,
               "One item",
               "%{count} items",
               22,
               %{}
             ) == {:ok, "22 przedmioty"}
    end
  end

  describe "plural with custom bindings (core logic)" do
    test "interpolates count and custom variables" do
      assert TestGettextWithCache.lngettext(
               "en",
               "default",
               nil,
               "One item",
               "%{count} items",
               3,
               %{extra: "test"}
             ) ==
               {:ok, "3 items"}
    end
  end

  describe "missing bindings handling (core logic)" do
    test "handles missing bindings gracefully" do
      assert {:missing_bindings, "Hello %{name}", [:name]} =
               TestGettextWithCache.lgettext("en", "default", nil, "Hello %{name}", %{})
    end
  end

  describe "error handling (core logic)" do
    test "handles unknown locales gracefully" do
      assert {:default, "One item"} =
               TestGettextWithCache.lngettext(
                 "xyz",
                 "default",
                 nil,
                 "One item",
                 "%{count} items",
                 1,
                 %{}
               )

      assert {:default, "2 items"} =
               TestGettextWithCache.lngettext(
                 "xyz",
                 "default",
                 nil,
                 "One item",
                 "%{count} items",
                 2,
                 %{}
               )
    end

    test "handles unknown domain gracefully" do
      assert {:default, "One item"} =
               TestGettextWithCache.lngettext(
                 "en",
                 "unknown_domain",
                 nil,
                 "One item",
                 "%{count} items",
                 1,
                 %{}
               )
    end

    test "handles unknown locales gracefully with appropriate logging" do
      log_output =
        capture_log(fn ->
          assert {:default, "One item"} =
                   TestGettextWithCache.lngettext(
                     "xyz",
                     "default",
                     nil,
                     "One item",
                     "%{count} items",
                     1,
                     %{}
                   )

          assert {:default, "2 items"} =
                   TestGettextWithCache.lngettext(
                     "xyz",
                     "default",
                     nil,
                     "One item",
                     "%{count} items",
                     2,
                     %{}
                   )
        end)

      assert log_output =~ "Kanta: Error calling plural function"
      assert log_output =~ "locale=\"xyz\""
      assert log_output =~ "Returning default plural index 0"
      # From Gettext.Plural
      assert log_output =~ "UnknownLocaleError"
    end
  end

  # --- Cache-Specific Behavior ---
  describe "caching behavior (when enabled)" do
    test "lgettext caches results and avoids repeated source lookups" do
      assert CallCounterAgent.get_count() == 0
      assert TestGettextWithCache.lgettext("fr", "default", nil, "Hello", %{}) == {:ok, "Bonjour"}
      assert CallCounterAgent.get_count() == 1

      # Cache Hit
      assert TestGettextWithCache.lgettext("fr", "default", nil, "Hello", %{}) == {:ok, "Bonjour"}

      assert CallCounterAgent.get_count() == 1,
             "Cache miss: Source was called again for identical lgettext"

      # Different locale
      assert TestGettextWithCache.lgettext("es", "default", nil, "Hello", %{}) == {:ok, "Hola"}
      assert CallCounterAgent.get_count() == 2

      # Different key
      assert TestGettextWithCache.lgettext("fr", "default", nil, "Hello %{name}", %{name: "Test"}) ==
               {:ok, "Bonjour Test"}

      assert CallCounterAgent.get_count() == 3

      # Cache Hit (interpolation happens after cache)
      assert TestGettextWithCache.lgettext("fr", "default", nil, "Hello %{name}", %{name: "Test"}) ==
               {:ok, "Bonjour Test"}

      assert CallCounterAgent.get_count() == 3,
             "Cache miss: Source was called again for identical lgettext with bindings"

      # Cache Hit (different bindings)
      assert TestGettextWithCache.lgettext("fr", "default", nil, "Hello %{name}", %{
               name: "Cached"
             }) == {:ok, "Bonjour Cached"}

      assert CallCounterAgent.get_count() == 3,
             "Cache miss: Source was called again for cached key with different bindings"
    end

    test "lngettext caches results based on plural index and avoids repeated source lookups" do
      assert CallCounterAgent.get_count() == 0

      # English n=1 -> index 0
      assert TestGettextWithCache.lngettext(
               "en",
               "default",
               nil,
               "One item",
               "%{count} items",
               1,
               %{}
             ) == {:ok, "One item"}

      assert CallCounterAgent.get_count() == 1
      # Cache Hit
      assert TestGettextWithCache.lngettext(
               "en",
               "default",
               nil,
               "One item",
               "%{count} items",
               1,
               %{}
             ) == {:ok, "One item"}

      assert CallCounterAgent.get_count() == 1,
             "Cache miss: Source called again for lngettext n=1 (index 0)"

      # English n=5 -> index 1
      assert TestGettextWithCache.lngettext(
               "en",
               "default",
               nil,
               "One item",
               "%{count} items",
               5,
               %{}
             ) == {:ok, "5 items"}

      assert CallCounterAgent.get_count() == 2
      # Cache Hit (different n, same index)
      assert TestGettextWithCache.lngettext(
               "en",
               "default",
               nil,
               "One item",
               "%{count} items",
               2,
               %{}
             ) == {:ok, "2 items"}

      assert CallCounterAgent.get_count() == 2,
             "Cache miss: Source called again for lngettext n=2 (index 1)"

      # French n=1 -> index 0
      assert TestGettextWithCache.lngettext(
               "fr",
               "default",
               nil,
               "One item",
               "%{count} items",
               1,
               %{}
             ) == {:ok, "Un objet"}

      assert CallCounterAgent.get_count() == 3
      # Cache Hit (different n, same index for fr)
      assert TestGettextWithCache.lngettext(
               "fr",
               "default",
               nil,
               "One item",
               "%{count} items",
               0,
               %{}
             ) == {:ok, "Un objet"}

      assert CallCounterAgent.get_count() == 3,
             "Cache miss: Source called again for fr lngettext n=0 (index 0)"

      # French n=2 -> index 1
      assert TestGettextWithCache.lngettext(
               "fr",
               "default",
               nil,
               "One item",
               "%{count} items",
               2,
               %{}
             ) == {:ok, "2 objets"}

      assert CallCounterAgent.get_count() == 4
      # Cache Hit (different n, same index for fr)
      assert TestGettextWithCache.lngettext(
               "fr",
               "default",
               nil,
               "One item",
               "%{count} items",
               5,
               %{}
             ) == {:ok, "5 objets"}

      assert CallCounterAgent.get_count() == 4,
             "Cache miss: Source called again for fr lngettext n=5 (index 1)"
    end

    test "missing translations ARE cached (avoids repeated source lookups)" do
      assert CallCounterAgent.get_count() == 0

      # First lookup for missing lgettext
      assert TestGettextWithCache.lgettext("en", "default", nil, "Missing Key", %{}) ==
               {:default, "Missing Key"}

      # Source was called once
      assert CallCounterAgent.get_count() == 1

      # Second lookup for the SAME missing lgettext
      assert TestGettextWithCache.lgettext("en", "default", nil, "Missing Key", %{}) ==
               {:default, "Missing Key"}

      # Source should NOT be called again due to cache hit on @not_found_marker
      assert CallCounterAgent.get_count() == 1,
             "Missing lgettext translation was NOT cached as expected"

      # First lookup for missing lngettext
      assert TestGettextWithCache.lngettext("en", "missing_domain", nil, "Sing", "Plur", 1, %{}) ==
               {:default, "Sing"}

      # Source was called again (different key/type)
      assert CallCounterAgent.get_count() == 2

      # Second lookup for the SAME missing lngettext
      assert TestGettextWithCache.lngettext("en", "missing_domain", nil, "Sing", "Plur", 1, %{}) ==
               {:default, "Sing"}

      # Source should NOT be called again due to cache hit on @not_found_marker
      assert CallCounterAgent.get_count() == 2,
             "Missing lngettext translation was NOT cached as expected"

      # Third lookup for SAME missing lngettext, different n but same plural index (0 for en, n=1)
      # This *should* still hit the same cache entry if the plural index is the same
      assert TestGettextWithCache.lngettext("en", "missing_domain", nil, "Sing", "Plur", 1, %{}) ==
               {:default, "Sing"}

      assert CallCounterAgent.get_count() == 2,
             "Missing lngettext translation (same index) was NOT cached as expected"

      # Fourth lookup for SAME missing lngettext, different n AND different plural index (1 for en, n=2)
      # This should be a new cache key lookup
      # Default handler interpolates count into plural string
      assert TestGettextWithCache.lngettext(
               "en",
               "missing_domain",
               nil,
               "Sing",
               "%{count} Plur",
               2,
               %{}
             ) ==
               {:default, "2 Plur"}

      # Source should be called again (new plural index)
      assert CallCounterAgent.get_count() == 3

      # Fifth lookup for the index 1 missing key
      assert TestGettextWithCache.lngettext(
               "en",
               "missing_domain",
               nil,
               "Sing",
               "%{count} Plur",
               2,
               %{}
             ) ==
               {:default, "2 Plur"}

      # Source should NOT be called again
      assert CallCounterAgent.get_count() == 3,
             "Missing lngettext translation (index 1) was NOT cached as expected"
    end
  end

  # --- Non-Caching Behavior Tests ---
  describe "non-caching behavior (when disabled)" do
    test "lgettext always calls the source when cache is disabled" do
      assert CallCounterAgent.get_count() == 0

      # First call
      assert TestGettextWithoutCache.lgettext("fr", "default", nil, "Hello", %{}) ==
               {:ok, "Bonjour"}

      assert CallCounterAgent.get_count() == 1

      # Second call (identical) - should hit source again
      assert TestGettextWithoutCache.lgettext("fr", "default", nil, "Hello", %{}) ==
               {:ok, "Bonjour"}

      assert CallCounterAgent.get_count() == 2,
             "Source should be called again for lgettext when cache is disabled"

      # Third call (different locale) - should hit source again
      assert TestGettextWithoutCache.lgettext("es", "default", nil, "Hello", %{}) ==
               {:ok, "Hola"}

      assert CallCounterAgent.get_count() == 3

      # Fourth call (different key) - should hit source again
      assert TestGettextWithoutCache.lgettext("fr", "default", nil, "Hello %{name}", %{
               name: "Test"
             }) == {:ok, "Bonjour Test"}

      assert CallCounterAgent.get_count() == 4

      # Fifth call (same key, different bindings) - should hit source again
      assert TestGettextWithoutCache.lgettext("fr", "default", nil, "Hello %{name}", %{
               name: "Cached"
             }) == {:ok, "Bonjour Cached"}

      assert CallCounterAgent.get_count() == 5,
             "Source should be called again for lgettext with different bindings when cache is disabled"
    end

    test "lngettext always calls the source when cache is disabled" do
      assert CallCounterAgent.get_count() == 0

      # First call (en, n=1)
      assert TestGettextWithoutCache.lngettext(
               "en",
               "default",
               nil,
               "One item",
               "%{count} items",
               1,
               %{}
             ) == {:ok, "One item"}

      assert CallCounterAgent.get_count() == 1

      # Second call (identical) - should hit source again
      assert TestGettextWithoutCache.lngettext(
               "en",
               "default",
               nil,
               "One item",
               "%{count} items",
               1,
               %{}
             ) == {:ok, "One item"}

      assert CallCounterAgent.get_count() == 2,
             "Source should be called again for same plural (n=1) when cache is disabled"

      # Third call (en, n=5) - should hit source again
      assert TestGettextWithoutCache.lngettext(
               "en",
               "default",
               nil,
               "One item",
               "%{count} items",
               5,
               %{}
             ) == {:ok, "5 items"}

      assert CallCounterAgent.get_count() == 3

      # Fourth call (en, n=2 - same plural index as n=5) - should hit source again
      assert TestGettextWithoutCache.lngettext(
               "en",
               "default",
               nil,
               "One item",
               "%{count} items",
               2,
               %{}
             ) == {:ok, "2 items"}

      assert CallCounterAgent.get_count() == 4,
             "Source should be called again for same plural index (n=2) when cache is disabled"

      # Fifth call (fr, n=1) - should hit source again
      assert TestGettextWithoutCache.lngettext(
               "fr",
               "default",
               nil,
               "One item",
               "%{count} items",
               1,
               %{}
             ) == {:ok, "Un objet"}

      assert CallCounterAgent.get_count() == 5
    end

    test "missing translations always hit source when cache is disabled" do
      assert CallCounterAgent.get_count() == 0

      # First call (missing lgettext)
      assert TestGettextWithoutCache.lgettext("en", "default", nil, "Missing Key", %{}) ==
               {:default, "Missing Key"}

      assert CallCounterAgent.get_count() == 1

      # Second call (identical missing lgettext) - should hit source again
      assert TestGettextWithoutCache.lgettext("en", "default", nil, "Missing Key", %{}) ==
               {:default, "Missing Key"}

      assert CallCounterAgent.get_count() == 2,
             "Source should be called again for missing lgettext when cache disabled"

      # Third call (missing lngettext, n=1)
      assert TestGettextWithoutCache.lngettext(
               "en",
               "missing_domain",
               nil,
               "Sing",
               "Plur",
               1,
               %{}
             ) == {:default, "Sing"}

      assert CallCounterAgent.get_count() == 3

      # Fourth call (identical missing lngettext) - should hit source again
      assert TestGettextWithoutCache.lngettext(
               "en",
               "missing_domain",
               nil,
               "Sing",
               "Plur",
               1,
               %{}
             ) == {:default, "Sing"}

      assert CallCounterAgent.get_count() == 4,
             "Source should be called again for missing lngettext when cache disabled"

      # Fifth call (missing lngettext, n=2) - should hit source again
      assert TestGettextWithoutCache.lngettext(
               "en",
               "missing_domain",
               nil,
               "Sing",
               "%{count} Plur",
               2,
               %{}
             ) == {:default, "2 Plur"}

      assert CallCounterAgent.get_count() == 5,
             "Source should be called again for missing lngettext (diff n) when cache disabled"
    end
  end
end
