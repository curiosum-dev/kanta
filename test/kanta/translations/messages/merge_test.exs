defmodule Kanta.Translations.Messages.MergeTest do
  use Kanta.Test.DataCase, async: false

  alias Kanta.Translations

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

    {:ok, locale_es} =
      Translations.create_locale(%{
        iso639_code: "es",
        name: "Spanish",
        native_name: "Español"
      })

    # Get or create domain
    domain =
      case Translations.get_domain(filter: [name: "default"]) do
        {:ok, domain} ->
          domain

        {:error, :domain, :not_found} ->
          {:ok, domain} = Translations.create_domain(%{name: "default"})
          domain
      end

    # Get or create context
    context =
      case Translations.get_context(filter: [name: "default"]) do
        {:ok, context} ->
          context

        {:error, :context, :not_found} ->
          {:ok, context} = Translations.create_context(%{name: "default"})
          context
      end

    %{
      locale_en: locale_en,
      locale_es: locale_es,
      domain: domain,
      context: context
    }
  end

  describe "merge_messages/2" do
    test "moves non-conflicting singular translations to target message", %{
      domain: domain,
      context: context,
      locale_en: locale_en,
      locale_es: locale_es
    } do
      # Create target message (already has correct msgid from PO files)
      {:ok, target_message} =
        Translations.create_message(%{
          msgid: "Hello world",
          message_type: :singular,
          domain_id: domain.id,
          context_id: context.id
        })

      # Target already has English translation
      {:ok, target_translation_en} =
        Translations.create_singular_translation(%{
          message_id: target_message.id,
          locale_id: locale_en.id,
          original_text: "Hello world",
          translated_text: "Hello world (en)"
        })

      # Create stale message (old msgid with typo)
      {:ok, stale_message} =
        Translations.create_message(%{
          msgid: "Hello wrold",
          message_type: :singular,
          domain_id: domain.id,
          context_id: context.id
        })

      # Stale has Spanish translation (no conflict - target doesn't have Spanish)
      {:ok, stale_translation_es} =
        Translations.create_singular_translation(%{
          message_id: stale_message.id,
          locale_id: locale_es.id,
          original_text: "Hello wrold",
          translated_text: "Hola mundo"
        })

      # Merge stale into target
      {:ok, result_message} = Translations.merge_messages(stale_message.id, target_message.id)

      # Result should be the target message
      assert result_message.id == target_message.id
      assert result_message.msgid == "Hello world"

      # Spanish translation should now belong to target message
      {:ok, moved_translation} =
        Translations.get_singular_translation(filter: [id: stale_translation_es.id])

      assert moved_translation.message_id == target_message.id

      # Target's original English translation should be deleted (replaced)
      assert {:error, :singular_translation, :not_found} =
               Translations.get_singular_translation(filter: [id: target_translation_en.id])

      # Stale message should be deleted
      assert {:error, :message, :not_found} =
               Translations.get_message(filter: [id: stale_message.id])
    end

    test "overwrites target translations with source translations", %{
      domain: domain,
      context: context,
      locale_en: locale_en
    } do
      # Create target message
      {:ok, target_message} =
        Translations.create_message(%{
          msgid: "Hello world",
          message_type: :singular,
          domain_id: domain.id,
          context_id: context.id
        })

      # Target has English translation
      {:ok, target_translation} =
        Translations.create_singular_translation(%{
          message_id: target_message.id,
          locale_id: locale_en.id,
          original_text: "Hello world",
          translated_text: "Target translation"
        })

      # Create source message
      {:ok, source_message} =
        Translations.create_message(%{
          msgid: "Hello wrold",
          message_type: :singular,
          domain_id: domain.id,
          context_id: context.id
        })

      # Source also has English translation
      {:ok, source_translation} =
        Translations.create_singular_translation(%{
          message_id: source_message.id,
          locale_id: locale_en.id,
          original_text: "Hello wrold",
          translated_text: "Source translation"
        })

      # Merge source into target (target's translations are deleted first)
      {:ok, _result} = Translations.merge_messages(source_message.id, target_message.id)

      # Target's old translation should be deleted
      assert {:error, :singular_translation, :not_found} =
               Translations.get_singular_translation(filter: [id: target_translation.id])

      # Source's translation should now belong to target
      {:ok, moved_translation} =
        Translations.get_singular_translation(filter: [id: source_translation.id])

      assert moved_translation.message_id == target_message.id
      assert moved_translation.translated_text == "Source translation"
    end

    test "moves non-conflicting plural translations to target message", %{
      domain: domain,
      context: context,
      locale_en: locale_en,
      locale_es: locale_es
    } do
      # Create target message
      {:ok, target_message} =
        Translations.create_message(%{
          msgid: "One item",
          msgid_plural: "Many items",
          message_type: :plural,
          domain_id: domain.id,
          context_id: context.id
        })

      # Target has English plural translations
      {:ok, _target_plural_en_0} =
        Translations.create_plural_translation(%{
          message_id: target_message.id,
          locale_id: locale_en.id,
          nplural_index: 0,
          original_text: "One item",
          translated_text: "One item (en)"
        })

      # Create stale message
      {:ok, stale_message} =
        Translations.create_message(%{
          msgid: "One itme",
          # typo
          msgid_plural: "Many itmes",
          message_type: :plural,
          domain_id: domain.id,
          context_id: context.id
        })

      # Stale has Spanish plural translations
      {:ok, stale_plural_es_0} =
        Translations.create_plural_translation(%{
          message_id: stale_message.id,
          locale_id: locale_es.id,
          nplural_index: 0,
          original_text: "One itme",
          translated_text: "Un elemento"
        })

      {:ok, stale_plural_es_1} =
        Translations.create_plural_translation(%{
          message_id: stale_message.id,
          locale_id: locale_es.id,
          nplural_index: 1,
          original_text: "Many itmes",
          translated_text: "Muchos elementos"
        })

      # Merge stale into target
      {:ok, _result} = Translations.merge_messages(stale_message.id, target_message.id)

      # Spanish plurals should now belong to target
      {:ok, moved_plural_0} =
        Translations.get_plural_translation(filter: [id: stale_plural_es_0.id])

      assert moved_plural_0.message_id == target_message.id

      {:ok, moved_plural_1} =
        Translations.get_plural_translation(filter: [id: stale_plural_es_1.id])

      assert moved_plural_1.message_id == target_message.id
    end

    test "works with mix of singular and plural translations", %{
      domain: domain,
      context: context,
      locale_en: locale_en,
      locale_es: locale_es
    } do
      # In real scenario, message_type shouldn't change, but test data flexibility
      {:ok, target_message} =
        Translations.create_message(%{
          msgid: "Item",
          message_type: :singular,
          domain_id: domain.id,
          context_id: context.id
        })

      {:ok, stale_message} =
        Translations.create_message(%{
          msgid: "Itme",
          message_type: :singular,
          domain_id: domain.id,
          context_id: context.id
        })

      # Create translations for both
      {:ok, target_en} =
        Translations.create_singular_translation(%{
          message_id: target_message.id,
          locale_id: locale_en.id,
          original_text: "Item",
          translated_text: "Item (target)"
        })

      {:ok, stale_es} =
        Translations.create_singular_translation(%{
          message_id: stale_message.id,
          locale_id: locale_es.id,
          original_text: "Itme",
          translated_text: "Elemento"
        })

      {:ok, _result} = Translations.merge_messages(stale_message.id, target_message.id)

      # Target's original translation should be deleted
      assert {:error, :singular_translation, :not_found} =
               Translations.get_singular_translation(filter: [id: target_en.id])

      # Source's translation should now belong to target
      {:ok, moved_translation} =
        Translations.get_singular_translation(filter: [id: stale_es.id])

      assert moved_translation.message_id == target_message.id

      # Only the source translation should exist on target
      target_translations =
        Translations.list_singular_translations(filter: [message_id: target_message.id])

      translation_ids =
        case target_translations do
          %{entries: entries} -> Enum.map(entries, & &1.id)
          entries when is_list(entries) -> Enum.map(entries, & &1.id)
        end

      assert stale_es.id in translation_ids
      assert length(translation_ids) == 1
    end
  end

  describe "merge_messages/2 - error handling" do
    test "returns error when source message not found" do
      {:ok, target_message} =
        Translations.create_message(%{
          msgid: "Target",
          message_type: :singular,
          domain_id: nil,
          context_id: nil
        })

      assert {:error, :message, :not_found} =
               Translations.merge_messages(999_999, target_message.id)
    end

    test "returns error when target message not found" do
      {:ok, source_message} =
        Translations.create_message(%{
          msgid: "Source",
          message_type: :singular,
          domain_id: nil,
          context_id: nil
        })

      assert {:error, :message, :not_found} =
               Translations.merge_messages(source_message.id, 999_999)
    end

    test "can merge messages from different domains", %{
      domain: domain,
      context: context
    } do
      # Create another domain
      {:ok, other_domain} = Translations.create_domain(%{name: "errors"})

      # Target message in "default" domain
      {:ok, target_message} =
        Translations.create_message(%{
          msgid: "Hello",
          message_type: :singular,
          domain_id: domain.id,
          context_id: context.id
        })

      # Source message in "errors" domain
      {:ok, source_message} =
        Translations.create_message(%{
          msgid: "Helo",
          message_type: :singular,
          domain_id: other_domain.id,
          context_id: context.id
        })

      # Merge should work even across domains
      {:ok, result_message} = Translations.merge_messages(source_message.id, target_message.id)

      # Result should be target message (unchanged domain)
      assert result_message.id == target_message.id
      assert result_message.msgid == "Hello"
      assert result_message.domain_id == domain.id

      # Source message should be deleted
      assert {:error, :message, :not_found} =
               Translations.get_message(filter: [id: source_message.id])
    end
  end

  describe "merge_messages/2 - cache invalidation" do
    test "invalidates cache after successful merge", %{
      domain: domain,
      context: context,
      locale_en: locale_en
    } do
      {:ok, source_message} =
        Translations.create_message(%{
          msgid: "Old",
          message_type: :singular,
          domain_id: domain.id,
          context_id: context.id
        })

      {:ok, target_message} =
        Translations.create_message(%{
          msgid: "New",
          message_type: :singular,
          domain_id: domain.id,
          context_id: context.id
        })

      {:ok, _translation} =
        Translations.create_singular_translation(%{
          message_id: source_message.id,
          locale_id: locale_en.id,
          original_text: "Old",
          translated_text: "Translation"
        })

      # Warm cache
      Translations.get_message(filter: [id: source_message.id])

      # Merge
      {:ok, _result} = Translations.merge_messages(source_message.id, target_message.id)

      # Verify source message is deleted (cache was cleared)
      assert {:error, :message, :not_found} =
               Translations.get_message(filter: [id: source_message.id])

      # Verify target message exists
      {:ok, fresh_target} = Translations.get_message(filter: [id: target_message.id])
      assert fresh_target.id == target_message.id
    end
  end
end
