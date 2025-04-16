defmodule Kanta.BackendTest do
  # Keep async if Agent is simple enough, otherwise set to false
  use ExUnit.Case, async: false
  import ExUnit.CaptureLog

  # --- Call Counter Agent ---
  # Used to track calls to the MockSource lookup functions
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

    # Helper to increment counter before returning result
    defp count_and_return(result) do
      CallCounterAgent.increment()
      result
    end

    def validate_opts(opts) do
      opts
    end

    def known_locales(_backend), do: ["en", "fr", "es", "pl"]

    def lookup_lgettext(_backend, "en", "default", nil, "Hello") do
      count_and_return({:ok, "Hello"})
    end

    def lookup_lgettext(_backend, "fr", "default", nil, "Hello") do
      count_and_return({:ok, "Bonjour"})
    end

    def lookup_lgettext(_backend, "es", "default", nil, "Hello") do
      count_and_return({:ok, "Hola"})
    end

    def lookup_lgettext(_backend, "en", "default", nil, "Hello %{name}") do
      count_and_return({:ok, "Hello %{name}"})
    end

    def lookup_lgettext(_backend, "fr", "default", nil, "Hello %{name}") do
      count_and_return({:ok, "Bonjour %{name}"})
    end

    def lookup_lgettext(_backend, "en", "errors", nil, "Not found") do
      count_and_return({:ok, "Not found"})
    end

    def lookup_lgettext(_backend, "fr", "errors", nil, "Not found") do
      count_and_return({:ok, "Pas trouvé"})
    end

    def lookup_lgettext(_backend, _, _, _, _) do
      count_and_return({:error, :not_found})
    end

    # --- Plural Lookups ---
    def lookup_lngettext(_backend, "en", "default", nil, "One item", "%{count} items", 0) do
      # Note: Gettext plural index 0 is singular for n=1 in English
      count_and_return({:ok, "One item"})
    end

    def lookup_lngettext(_backend, "en", "default", nil, "One item", "%{count} items", 1) do
      # Plural index 1 is for n != 1
      count_and_return({:ok, "%{count} items"})
    end

    def lookup_lngettext(_backend, "fr", "default", nil, "One item", "%{count} items", 0) do
      # French index 0 is for n=0 or n=1
      count_and_return({:ok, "Un objet"})
    end

    def lookup_lngettext(_backend, "fr", "default", nil, "One item", "%{count} items", 1) do
      # French index 1 is for n > 1
      count_and_return({:ok, "%{count} objets"})
    end

    def lookup_lngettext(_backend, "es", "default", nil, "One item", "%{count} items", 0) do
      # Spanish index 0 is for n=1
      count_and_return({:ok, "Un artículo"})
    end

    def lookup_lngettext(_backend, "es", "default", nil, "One item", "%{count} items", 1) do
      # Spanish index 1 is for n != 1
      count_and_return({:ok, "%{count} artículos"})
    end

    def lookup_lngettext(_backend, "pl", "default", nil, "One item", "%{count} items", 0) do
      # Polish index 0 (n=1)
      count_and_return({:ok, "Jeden przedmiot"})
    end

    def lookup_lngettext(_backend, "pl", "default", nil, "One item", "%{count} items", 1) do
      # Polish index 1 (n=2,3,4 mod 10, !12,13,14)
      count_and_return({:ok, "%{count} przedmioty"})
    end

    def lookup_lngettext(_backend, "pl", "default", nil, "One item", "%{count} items", 2) do
      # Polish index 2 (other)
      count_and_return({:ok, "%{count} przedmiotów"})
    end

    def lookup_lngettext(_backend, _, _, _, _, _, _) do
      count_and_return({:error, :not_found})
    end
  end

  # --- Test Gettext Modules ---
  defmodule TestGettext do
    use Kanta.Backend,
      otp_app: :kanta_test,
      source: Kanta.BackendTest.MockSource,
      cache: Kanta.Cache
  end

  defmodule DefaultAdapterGettext do
    use Kanta.Backend, otp_app: :kanta_test, source_opts: [repo: nil]
  end

  # --- Setup ---
  # Start the counter agent and reset it before each test
  setup do
    # Start the agent if it's not running (relevant for first test run)
    {:ok, _pid} = CallCounterAgent.start_link([])
    # Reset the counter for the current test
    CallCounterAgent.reset()
    Kanta.Cache.delete_all()
    :ok
  end

  # --- Existing Describe Blocks (Keep As Is) ---

  describe "backend configuration" do
    # ... (tests remain the same) ...
    test "returns correct configuration values" do
      assert TestGettext.__gettext__(:otp_app) == :kanta_test
      assert TestGettext.__gettext__(:default_locale) == "en"
      assert TestGettext.__gettext__(:default_domain) == "default"
      assert is_binary(TestGettext.__gettext__(:priv))
      assert TestGettext.__gettext__(:known_locales) == ["en", "fr", "es", "pl"]
    end

    test "uses the specified adapter" do
      assert TestGettext.__gettext__(:known_locales) == ["en", "fr", "es", "pl"]
    end

    test "uses default adapter when none specified" do
      assert DefaultAdapterGettext.__gettext__(:otp_app) == :kanta_test
    end
  end

  describe "gettext translation" do
    # ... (tests remain the same, they implicitly test cache correctness) ...
    test "translates simple strings" do
      assert TestGettext.lgettext("en", "default", nil, "Hello", %{}) == {:ok, "Hello"}
      assert TestGettext.lgettext("fr", "default", nil, "Hello", %{}) == {:ok, "Bonjour"}
      assert TestGettext.lgettext("es", "default", nil, "Hello", %{}) == {:ok, "Hola"}
    end

    test "handles interpolation" do
      assert TestGettext.lgettext("en", "default", nil, "Hello %{name}", %{name: "John"}) ==
               {:ok, "Hello John"}

      assert TestGettext.lgettext("fr", "default", nil, "Hello %{name}", %{name: "Jean"}) ==
               {:ok, "Bonjour Jean"}
    end

    test "uses different domains" do
      assert TestGettext.lgettext("en", "errors", nil, "Not found", %{}) == {:ok, "Not found"}
      assert TestGettext.lgettext("fr", "errors", nil, "Not found", %{}) == {:ok, "Pas trouvé"}
    end

    test "returns default translation when not found" do
      assert TestGettext.lgettext("en", "default", nil, "Missing translation", %{}) ==
               {:default, "Missing translation"}

      assert TestGettext.lgettext("unknown", "default", nil, "Hello", %{}) ==
               {:default, "Hello"}
    end
  end

  describe "plural translations" do
    # ... (tests remain the same, they implicitly test cache correctness) ...
    # Note: We need to adjust expected plural indices based on Gettext.Plural rules
    # English: n=1 -> index 0, n!=1 -> index 1
    # French: n=0 or n=1 -> index 0, n>1 -> index 1

    test "handles singular forms (n=1)" do
      # English n=1 uses index 0 in MockSource
      assert TestGettext.lngettext("en", "default", nil, "One item", "%{count} items", 1, %{}) ==
               {:ok, "One item"}

      # French n=1 uses index 0 in MockSource
      assert TestGettext.lngettext("fr", "default", nil, "One item", "%{count} items", 1, %{}) ==
               {:ok, "Un objet"}
    end

    test "handles plural forms" do
      # English n=0 uses index 1 in MockSource
      assert TestGettext.lngettext("en", "default", nil, "One item", "%{count} items", 0, %{}) ==
               {:ok, "0 items"}

      # English n=5 uses index 1 in MockSource
      assert TestGettext.lngettext("en", "default", nil, "One item", "%{count} items", 5, %{}) ==
               {:ok, "5 items"}

      # French n=0 uses index 0 in MockSource
      # Note: MockSource lookup for index 0 returns "Un objet"
      assert TestGettext.lngettext("fr", "default", nil, "One item", "%{count} items", 0, %{}) ==
               {:ok, "Un objet"}

      # French n=5 uses index 1 in MockSource
      assert TestGettext.lngettext("fr", "default", nil, "One item", "%{count} items", 5, %{}) ==
               {:ok, "5 objets"}
    end

    test "falls back to default when translation not found" do
      assert TestGettext.lngettext("en", "unknown", nil, "One thing", "%{count} things", 1, %{}) ==
               {:default, "One thing"}

      assert TestGettext.lngettext("en", "unknown", nil, "One thing", "%{count} things", 2, %{}) ==
               {:default, "2 things"}
    end
  end

  describe "plural forms handling" do
    # Note: Adjusted expectations based on standard Gettext.Plural rules mapping to MockSource indices
    test "uses correct plural form for English" do
      # n=1 -> index 0
      assert TestGettext.lngettext("en", "default", nil, "One item", "%{count} items", 1, %{}) ==
               {:ok, "One item"}

      # n=0 -> index 1
      assert TestGettext.lngettext("en", "default", nil, "One item", "%{count} items", 0, %{}) ==
               {:ok, "0 items"}

      # n=2 -> index 1
      assert TestGettext.lngettext("en", "default", nil, "One item", "%{count} items", 2, %{}) ==
               {:ok, "2 items"}

      # n=5 -> index 1
      assert TestGettext.lngettext("en", "default", nil, "One item", "%{count} items", 5, %{}) ==
               {:ok, "5 items"}
    end

    test "uses correct plural form for French" do
      # n=1 -> index 0
      assert TestGettext.lngettext("fr", "default", nil, "One item", "%{count} items", 1, %{}) ==
               {:ok, "Un objet"}

      # n=0 -> index 0
      # Should return the singular form according to rule nplurals=2; plural=(n > 1);
      assert TestGettext.lngettext("fr", "default", nil, "One item", "%{count} items", 0, %{}) ==
               {:ok, "Un objet"}

      # n=2 -> index 1
      assert TestGettext.lngettext("fr", "default", nil, "One item", "%{count} items", 2, %{}) ==
               {:ok, "2 objets"}
    end

    test "uses correct plural form for Spanish" do
      # n=1 -> index 0
      assert TestGettext.lngettext("es", "default", nil, "One item", "%{count} items", 1, %{}) ==
               {:ok, "Un artículo"}

      # n=2 -> index 1
      assert TestGettext.lngettext("es", "default", nil, "One item", "%{count} items", 2, %{}) ==
               {:ok, "2 artículos"}
    end

    test "handles languages with complex plural rules (Polish)" do
      # Polish Rules (approx): n=1 -> idx 0; n=2,3,4 (ends in) -> idx 1; others -> idx 2
      # n=1 -> index 0
      assert TestGettext.lngettext("pl", "default", nil, "One item", "%{count} items", 1, %{}) ==
               {:ok, "Jeden przedmiot"}

      # n=2 -> index 1
      assert TestGettext.lngettext("pl", "default", nil, "One item", "%{count} items", 2, %{}) ==
               {:ok, "2 przedmioty"}

      # n=5 -> index 2
      assert TestGettext.lngettext("pl", "default", nil, "One item", "%{count} items", 5, %{}) ==
               {:ok, "5 przedmiotów"}

      # n=12 -> index 2
      assert TestGettext.lngettext("pl", "default", nil, "One item", "%{count} items", 12, %{}) ==
               {:ok, "12 przedmiotów"}

      # n=22 -> index 1
      assert TestGettext.lngettext("pl", "default", nil, "One item", "%{count} items", 22, %{}) ==
               {:ok, "22 przedmioty"}
    end
  end

  describe "plural with custom bindings" do
    # ... (tests remain the same) ...
    test "interpolates count and custom variables" do
      assert TestGettext.lngettext(
               "en",
               "default",
               nil,
               "One item",
               "%{count} items",
               # n=3 -> index 1 for english
               3,
               %{extra: "test"}
             ) == {:ok, "3 items"}
    end
  end

  describe "missing bindings handling" do
    # ... (tests remain the same) ...
    test "handles missing bindings gracefully" do
      assert {:missing_bindings, "Hello %{name}", [:name]} =
               TestGettext.lgettext("en", "default", nil, "Hello %{name}", %{})
    end
  end

  describe "error handling" do
    # ... (tests remain the same) ...
    test "handles unknown locales gracefully" do
      assert {:default, "One item"} =
               TestGettext.lngettext("xyz", "default", nil, "One item", "%{count} items", 1, %{})

      assert {:default, "2 items"} =
               TestGettext.lngettext("xyz", "default", nil, "One item", "%{count} items", 2, %{})
    end

    test "handles unknown domain gracefully" do
      assert {:default, "One item"} =
               TestGettext.lngettext(
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
                   TestGettext.lngettext(
                     "xyz",
                     "default",
                     nil,
                     "One item",
                     "%{count} items",
                     1,
                     %{}
                   )

          assert {:default, "2 items"} =
                   TestGettext.lngettext(
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
      # This comes from Gettext.Plural
      assert log_output =~ "UnknownLocaleError"
    end
  end

  # --- NEW: Caching Behavior Tests ---
  describe "caching behavior" do
    test "lgettext caches results and avoids repeated source lookups" do
      # Initial state: counter is 0 (from setup)
      assert CallCounterAgent.get_count() == 0

      # First call: Hits the source
      assert TestGettext.lgettext("fr", "default", nil, "Hello", %{}) == {:ok, "Bonjour"}
      assert CallCounterAgent.get_count() == 1

      # Second identical call: Should hit cache, source count remains 1
      assert TestGettext.lgettext("fr", "default", nil, "Hello", %{}) == {:ok, "Bonjour"}

      assert CallCounterAgent.get_count() == 1,
             "Cache miss: Source was called again for identical lgettext"

      # Call with different locale: Hits the source again
      assert TestGettext.lgettext("es", "default", nil, "Hello", %{}) == {:ok, "Hola"}
      assert CallCounterAgent.get_count() == 2

      # Call with same locale, different key: Hits the source again
      assert TestGettext.lgettext("fr", "default", nil, "Hello %{name}", %{name: "Test"}) ==
               {:ok, "Bonjour Test"}

      assert CallCounterAgent.get_count() == 3

      # Repeat previous call: Should hit cache now
      assert TestGettext.lgettext("fr", "default", nil, "Hello %{name}", %{name: "Test"}) ==
               {:ok, "Bonjour Test"}

      assert CallCounterAgent.get_count() == 3,
             "Cache miss: Source was called again for identical lgettext with bindings"

      # Test interpolation happens *after* cache retrieval
      assert TestGettext.lgettext("fr", "default", nil, "Hello %{name}", %{name: "Cached"}) ==
               {:ok, "Bonjour Cached"}

      assert CallCounterAgent.get_count() == 3,
             "Cache miss: Source was called again for cached key with different bindings"
    end

    test "lngettext caches results based on plural index and avoids repeated source lookups" do
      # Initial state: counter is 0
      assert CallCounterAgent.get_count() == 0

      # --- English ---
      # First call (n=1 -> index 0): Hits the source
      assert TestGettext.lngettext("en", "default", nil, "One item", "%{count} items", 1, %{}) ==
               {:ok, "One item"}

      assert CallCounterAgent.get_count() == 1

      # Second identical call (n=1 -> index 0): Should hit cache
      assert TestGettext.lngettext("en", "default", nil, "One item", "%{count} items", 1, %{}) ==
               {:ok, "One item"}

      assert CallCounterAgent.get_count() == 1,
             "Cache miss: Source called again for lngettext n=1 (index 0)"

      # Third call (n=5 -> index 1): Hits the source (different plural index)
      assert TestGettext.lngettext("en", "default", nil, "One item", "%{count} items", 5, %{}) ==
               {:ok, "5 items"}

      assert CallCounterAgent.get_count() == 2

      # Fourth call (n=2 -> index 1): Should hit cache (same plural index as n=5)
      assert TestGettext.lngettext("en", "default", nil, "One item", "%{count} items", 2, %{}) ==
               {:ok, "2 items"}

      assert CallCounterAgent.get_count() == 2,
             "Cache miss: Source called again for lngettext n=2 (index 1)"

      # --- French (Different locale, different plural rules) ---
      # n=1 -> index 0
      assert TestGettext.lngettext("fr", "default", nil, "One item", "%{count} items", 1, %{}) ==
               {:ok, "Un objet"}

      # New source lookup
      assert CallCounterAgent.get_count() == 3

      # n=0 -> index 0 (same index as n=1 for French)
      assert TestGettext.lngettext("fr", "default", nil, "One item", "%{count} items", 0, %{}) ==
               {:ok, "Un objet"}

      assert CallCounterAgent.get_count() == 3,
             "Cache miss: Source called again for fr lngettext n=0 (index 0)"

      # n=2 -> index 1
      assert TestGettext.lngettext("fr", "default", nil, "One item", "%{count} items", 2, %{}) ==
               {:ok, "2 objets"}

      # New source lookup
      assert CallCounterAgent.get_count() == 4

      # n=5 -> index 1
      assert TestGettext.lngettext("fr", "default", nil, "One item", "%{count} items", 5, %{}) ==
               {:ok, "5 objets"}

      assert CallCounterAgent.get_count() == 4,
             "Cache miss: Source called again for fr lngettext n=5 (index 1)"
    end

    test "missing translations are NOT cached" do
      # Initial state: counter is 0
      assert CallCounterAgent.get_count() == 0

      # First call for missing key: Hits the source (and gets :not_found)
      assert TestGettext.lgettext("en", "default", nil, "Missing Key", %{}) ==
               {:default, "Missing Key"}

      # Source lookup happened
      assert CallCounterAgent.get_count() == 1

      # Second call for same missing key: Should hit the source again
      assert TestGettext.lgettext("en", "default", nil, "Missing Key", %{}) ==
               {:default, "Missing Key"}

      assert CallCounterAgent.get_count() == 2, "Missing translation was incorrectly cached"

      # First call for missing plural: Hits the source
      assert TestGettext.lngettext("en", "missing_domain", nil, "Sing", "Plur", 1, %{}) ==
               {:default, "Sing"}

      assert CallCounterAgent.get_count() == 3

      # Second call for missing plural: Hits the source again
      assert TestGettext.lngettext("en", "missing_domain", nil, "Sing", "Plur", 1, %{}) ==
               {:default, "Sing"}

      assert CallCounterAgent.get_count() == 4,
             "Missing plural translation was incorrectly cached"
    end
  end
end
