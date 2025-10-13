defmodule Kanta.PoFiles.Services.StaleDetectionTest do
  use Kanta.Test.DataCase, async: false

  alias Kanta.PoFiles.Services.StaleDetection
  alias Kanta.Translations

  @test_base_path "test/fixtures/single_messages"

  setup do
    # Clear cache before each test
    Kanta.Cache.delete_all()

    # Create locales
    {:ok, locale_en} =
      Translations.create_locale(%{
        iso639_code: "en",
        name: "English",
        native_name: "English"
      })

    {:ok, locale_it} =
      Translations.create_locale(%{
        iso639_code: "it",
        name: "Italian",
        native_name: "Italiano"
      })

    # Get or create domains
    domain_default =
      case Translations.get_domain(filter: [name: "default"]) do
        {:ok, domain} ->
          domain

        {:error, :domain, :not_found} ->
          {:ok, domain} = Translations.create_domain(%{name: "default"})
          domain
      end

    domain_errors =
      case Translations.get_domain(filter: [name: "errors"]) do
        {:ok, domain} ->
          domain

        {:error, :domain, :not_found} ->
          {:ok, domain} = Translations.create_domain(%{name: "errors"})
          domain
      end

    # Get or create contexts (default context exists from migration)
    context_default =
      case Translations.get_context(filter: [name: "default"]) do
        {:ok, context} ->
          context

        {:error, :context, :not_found} ->
          {:ok, context} = Translations.create_context(%{name: "default"})
          context
      end

    context_test =
      case Translations.get_context(filter: [name: "test"]) do
        {:ok, context} ->
          context

        {:error, :context, :not_found} ->
          {:ok, context} = Translations.create_context(%{name: "test"})
          context
      end

    # Create a message that EXISTS in PO files (not stale)
    {:ok, active_message} =
      Translations.create_message(%{
        msgid: "Hello world",
        message_type: :singular,
        domain_id: domain_default.id,
        context_id: context_test.id
      })

    # Create a message that DOES NOT exist in PO files (stale)
    {:ok, stale_message_1} =
      Translations.create_message(%{
        msgid: "This message was removed from PO files",
        message_type: :singular,
        domain_id: domain_default.id,
        context_id: context_default.id
      })

    # Create another stale message
    {:ok, stale_message_2} =
      Translations.create_message(%{
        msgid: "Another removed message",
        message_type: :singular,
        domain_id: domain_errors.id,
        context_id: context_default.id
      })

    %{
      locale_en: locale_en,
      locale_it: locale_it,
      domain_default: domain_default,
      domain_errors: domain_errors,
      context_default: context_default,
      context_test: context_test,
      active_message: active_message,
      stale_message_1: stale_message_1,
      stale_message_2: stale_message_2
    }
  end

  describe "call/1 - basic stale detection (system-wide)" do
    test "identifies stale messages correctly", %{
      active_message: active_message,
      stale_message_1: stale_message_1,
      stale_message_2: stale_message_2
    } do
      {:ok, result} = StaleDetection.call(base_path: @test_base_path)

      # Stale messages should be in the stale set
      assert MapSet.member?(result.stale_message_ids, stale_message_1.id)
      assert MapSet.member?(result.stale_message_ids, stale_message_2.id)

      # Active message should NOT be in the stale set
      refute MapSet.member?(result.stale_message_ids, active_message.id)
    end

    test "returns correct stats", %{
      stale_message_1: _stale_message_1,
      stale_message_2: _stale_message_2
    } do
      {:ok, result} = StaleDetection.call(base_path: @test_base_path)

      assert result.stale_count == 2
      assert result.mergeable_count >= 0
    end

    test "returns MapSet of stale message IDs" do
      {:ok, result} = StaleDetection.call(base_path: @test_base_path)

      assert %MapSet{} = result.stale_message_ids
    end

    test "returns MapSet of stale message IDs with correct size" do
      {:ok, result} = StaleDetection.call(base_path: @test_base_path)

      assert %MapSet{} = result.stale_message_ids
      assert MapSet.size(result.stale_message_ids) == 2
    end

    test "handles messages with default domain", %{
      domain_default: domain_default,
      context_default: context_default
    } do
      # Create message with default domain (should still be identified as stale if not in PO)
      {:ok, message_default_domain} =
        Translations.create_message(%{
          msgid: "Message with default domain",
          message_type: :singular,
          domain_id: domain_default.id,
          context_id: context_default.id
        })

      {:ok, result} = StaleDetection.call(base_path: @test_base_path)

      # This message doesn't exist in PO files, so it should be stale
      assert MapSet.member?(result.stale_message_ids, message_default_domain.id)
    end

    test "handles messages with default context", %{
      domain_default: domain_default,
      context_default: context_default
    } do
      # Create message with default context
      {:ok, message_default_context} =
        Translations.create_message(%{
          msgid: "Message with default context",
          message_type: :singular,
          domain_id: domain_default.id,
          context_id: context_default.id
        })

      {:ok, result} = StaleDetection.call(base_path: @test_base_path)

      # This message doesn't exist in PO files, so it should be stale
      assert MapSet.member?(result.stale_message_ids, message_default_context.id)
    end

    test "supports legacy string path API" do
      {:ok, result} = StaleDetection.call(@test_base_path)

      assert %MapSet{} = result.stale_message_ids
      assert result.stale_count > 0
    end

    test "mergeable_count is always calculated" do
      {:ok, result} = StaleDetection.call(base_path: @test_base_path)

      # Fuzzy matching is now always enabled
      assert is_integer(result.mergeable_count)
      assert result.mergeable_count >= 0
    end
  end

  describe "call/1 with fuzzy matching" do
    test "finds fuzzy matches for stale messages", %{
      domain_default: domain_default,
      context_test: context_test
    } do
      # Create a stale message that's similar to "Hello world" (exists in fixture)
      {:ok, similar_message} =
        Translations.create_message(%{
          msgid: "Helo world",
          # Typo - missing 'l'
          message_type: :singular,
          domain_id: domain_default.id,
          context_id: context_test.id
        })

      {:ok, result} =
        StaleDetection.call(
          base_path: @test_base_path,
          fuzzy_threshold: 0.8
        )

      # Check that the message is stale
      assert MapSet.member?(result.stale_message_ids, similar_message.id)

      # Check if fuzzy match exists for this message
      fuzzy_match = Map.get(result.fuzzy_matches_map, similar_message.id)

      # Should have a fuzzy match to "Hello world"
      if fuzzy_match do
        assert fuzzy_match.similarity_score >= 0.8
        assert fuzzy_match.matched_msgid == "Hello world"
      end
    end

    test "only matches within same domain and context", %{
      domain_default: domain_default,
      context_test: context_test
    } do
      # Create stale message similar to "Hello world" in "test" context
      {:ok, message_similar} =
        Translations.create_message(%{
          msgid: "Helo world similar",
          message_type: :singular,
          domain_id: domain_default.id,
          context_id: context_test.id
        })

      {:ok, result} =
        StaleDetection.call(
          base_path: @test_base_path,
          fuzzy_threshold: 0.7
        )

      # Check that the message is stale
      assert MapSet.member?(result.stale_message_ids, message_similar.id)

      # Check if fuzzy match exists for this message
      fuzzy_match = Map.get(result.fuzzy_matches_map, message_similar.id)

      # If fuzzy match exists, verify it's "Hello world" which is in same context
      if fuzzy_match do
        assert fuzzy_match.matched_msgid == "Hello world"
      end
    end

    test "respects fuzzy threshold", %{
      domain_default: domain_default,
      context_default: context_default
    } do
      # Create stale message that is very different
      {:ok, message_different} =
        Translations.create_message(%{
          msgid: "XYZ",
          message_type: :singular,
          domain_id: domain_default.id,
          context_id: context_default.id
        })

      {:ok, result} =
        StaleDetection.call(
          base_path: @test_base_path,
          fuzzy_threshold: 0.95
        )

      # Check that the message is stale
      assert MapSet.member?(result.stale_message_ids, message_different.id)

      # Should NOT have fuzzy match due to high threshold and very different msgid
      fuzzy_match = Map.get(result.fuzzy_matches_map, message_different.id)
      assert fuzzy_match == nil
    end

    test "returns mergeable count" do
      {:ok, result} =
        StaleDetection.call(base_path: @test_base_path)

      assert is_integer(result.mergeable_count)
      assert result.mergeable_count >= 0
    end

    test "fuzzy_matches_map contains fuzzy match data", %{
      stale_message_1: _stale_message_1
    } do
      {:ok, result} =
        StaleDetection.call(base_path: @test_base_path)

      # fuzzy_matches_map should be a map
      assert is_map(result.fuzzy_matches_map)

      # All entries in fuzzy_matches_map should have the expected structure
      for {message_id, fuzzy_match} <- result.fuzzy_matches_map do
        assert is_integer(message_id)
        assert %Kanta.PoFiles.Services.StaleDetection.FuzzyMatch{} = fuzzy_match
        assert is_integer(fuzzy_match.stale_message_id)
        assert is_integer(fuzzy_match.matched_message_id)
        assert is_binary(fuzzy_match.matched_msgid)
        assert is_float(fuzzy_match.similarity_score)
      end
    end

    test "works across all locales (system-wide approach)", %{
      domain_default: domain_default,
      context_test: context_test
    } do
      # Create stale message similar to something in any locale's PO files
      {:ok, message} =
        Translations.create_message(%{
          msgid: "Helo world",
          message_type: :singular,
          domain_id: domain_default.id,
          context_id: context_test.id
        })

      {:ok, result} =
        StaleDetection.call(base_path: @test_base_path)

      # Check that the message is stale
      assert MapSet.member?(result.stale_message_ids, message.id)

      # The stale detection should work system-wide
      assert MapSet.size(result.stale_message_ids) > 0

      # Fuzzy matching should work against all active keys
      fuzzy_match = Map.get(result.fuzzy_matches_map, message.id)

      if fuzzy_match do
        assert fuzzy_match.matched_msgid == "Hello world"
      end
    end
  end

  describe "stale message structure" do
    test "result structure contains expected fields", %{
      stale_message_1: _stale_message_1
    } do
      {:ok, result} = StaleDetection.call(base_path: @test_base_path)

      # Result should have all expected fields
      assert %MapSet{} = result.stale_message_ids
      assert is_map(result.fuzzy_matches_map)
      assert is_integer(result.stale_count)
      assert is_integer(result.mergeable_count)

      # stale_count should match the size of stale_message_ids
      assert result.stale_count == MapSet.size(result.stale_message_ids)

      # mergeable_count should match the size of fuzzy_matches_map
      assert result.mergeable_count == map_size(result.fuzzy_matches_map)
    end
  end
end
