defmodule Kanta.POFiles.Services.IdentifyStaleTranslationsTest do
  use Kanta.Test.DataCase, async: false

  alias Kanta.POFiles.Services.IdentifyStaleTranslations
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
      locale: locale_en,
      domain_default: domain_default,
      domain_errors: domain_errors,
      context_default: context_default,
      context_test: context_test,
      active_message: active_message,
      stale_message_1: stale_message_1,
      stale_message_2: stale_message_2
    }
  end

  describe "call/1" do
    test "identifies stale messages correctly (system-wide)", %{
      active_message: active_message,
      stale_message_1: stale_message_1,
      stale_message_2: stale_message_2
    } do
      {:ok, result} = IdentifyStaleTranslations.call(@test_base_path)

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
      {:ok, result} = IdentifyStaleTranslations.call(@test_base_path)

      assert result.stats.total_db_messages == 3
      assert result.stats.stale_count == 2
      assert result.stats.active_count > 0
    end

    test "returns MapSet of stale message IDs" do
      {:ok, result} = IdentifyStaleTranslations.call(@test_base_path)

      assert %MapSet{} = result.stale_message_ids
    end

    test "returns MapSet of active keys from PO files across all locales" do
      {:ok, result} = IdentifyStaleTranslations.call(@test_base_path)

      assert %MapSet{} = result.active_keys
      assert MapSet.size(result.active_keys) > 0
    end

    test "handles messages with nil domain", %{context_default: context_default} do
      # Create message with nil domain (should still be identified as stale if not in PO)
      {:ok, message_no_domain} =
        Translations.create_message(%{
          msgid: "Message without domain",
          message_type: :singular,
          domain_id: nil,
          context_id: context_default.id
        })

      {:ok, result} = IdentifyStaleTranslations.call(@test_base_path)

      # This message doesn't exist in PO files, so it should be stale
      assert MapSet.member?(result.stale_message_ids, message_no_domain.id)
    end

    test "handles messages with nil context", %{domain_default: domain_default} do
      # Create message with nil context
      {:ok, message_no_context} =
        Translations.create_message(%{
          msgid: "Message without context",
          message_type: :singular,
          domain_id: domain_default.id,
          context_id: nil
        })

      {:ok, result} = IdentifyStaleTranslations.call(@test_base_path)

      # This message doesn't exist in PO files, so it should be stale
      assert MapSet.member?(result.stale_message_ids, message_no_context.id)
    end
  end
end
