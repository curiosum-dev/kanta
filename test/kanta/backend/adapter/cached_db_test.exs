defmodule Kanta.Backend.Adapter.CachedDBTest do
  # Changing back to async: false for now
  use Kanta.Test.DataCase, async: false

  alias Kanta.Translations
  alias Kanta.Backend.Adapter.CachedDB

  setup do
    # Clear the cache before each test
    Kanta.Cache.delete_all()

    # Create test data in database
    {:ok, locale} =
      Translations.create_locale(%{
        native_name: "Français",
        name: "French",
        iso639_code: "fr",
        plurals_header: "nplurals=2; plural=(n > 1);"
      })

    {:ok, domain} = Translations.create_domain(%{name: "test_domain"})
    {:ok, context} = Translations.create_context(%{name: "test_context"})

    # Create a message for singular translation test
    {:ok, singular_message} =
      Translations.create_message(%{
        message_type: :singular,
        msgid: "Hello world",
        context_id: context.id,
        domain_id: domain.id
      })

    # Create a message for plural translation test
    {:ok, plural_message} =
      Translations.create_message(%{
        message_type: :plural,
        msgid: "%{count} items",
        context_id: context.id,
        domain_id: domain.id
      })

    # Create the actual translations
    {:ok, _singular_translation} =
      Translations.create_singular_translation(%{
        locale_id: locale.id,
        message_id: singular_message.id,
        translated_text: "Bonjour le monde"
      })

    # Create plural translations for both forms
    {:ok, _plural_translation_one} =
      Translations.create_plural_translation(%{
        locale_id: locale.id,
        message_id: plural_message.id,
        nplural_index: 0,
        translated_text: "%{count} élément"
      })

    {:ok, _plural_translation_many} =
      Translations.create_plural_translation(%{
        locale_id: locale.id,
        message_id: plural_message.id,
        nplural_index: 1,
        translated_text: "%{count} éléments"
      })

    {:ok, %{locale: locale, domain: domain, context: context}}
  end

  describe "lgettext/5" do
    test "returns translation from database for existing message" do
      result = CachedDB.lgettext("fr", "test_domain", "test_context", "Hello world", %{})
      assert result == {:ok, "Bonjour le monde"}
    end

    test "returns error for non-existing translation" do
      result = CachedDB.lgettext("fr", "test_domain", "test_context", "Non-existent message", %{})

      assert result == {:error, :not_found}
    end

    test "returns error for non-existing locale" do
      result = CachedDB.lgettext("de", "test_domain", "test_context", "Hello world", %{})
      assert result == {:error, :not_found}
    end

    test "interpolates variables correctly", %{locale: locale, domain: domain} do
      # Create message and translation for interpolation test
      {:ok, message} =
        Translations.create_message(%{
          message_type: :singular,
          msgid: "Hello %{name}",
          context_id: nil,
          domain_id: domain.id
        })

      {:ok, _translation} =
        Translations.create_singular_translation(%{
          locale_id: locale.id,
          message_id: message.id,
          translated_text: "Bonjour %{name}"
        })

      # Clear cache to ensure fresh state
      Kanta.Cache.delete_all()

      result = CachedDB.lgettext("fr", "test_domain", nil, "Hello %{name}", %{name: "Alice"})
      assert result == {:ok, "Bonjour Alice"}
    end
  end

  describe "lngettext/7" do
    test "returns singular form for count = 1", %{
      locale: locale,
      domain: domain,
      context: context
    } do
      # Create a specific message for singular test
      {:ok, message} =
        Translations.create_message(%{
          message_type: :singular,
          msgid: "One item",
          context_id: context.id,
          domain_id: domain.id
        })

      # Change the translation to expect interpolation
      {:ok, _translation} =
        Translations.create_singular_translation(%{
          locale_id: locale.id,
          message_id: message.id,
          # Changed from "Un élément"
          translated_text: "%{count} élément"
        })

      # Clear cache to ensure fresh state
      Kanta.Cache.delete_all()

      result =
        CachedDB.lngettext(
          "fr",
          "test_domain",
          "test_context",
          "One item",
          "%{count} items",
          1,
          %{}
        )

      # Changed from "Un élément"
      assert result == {:ok, "1 élément"}
    end

    test "returns plural form for count > 1" do
      # Use the plural message set up in the main setup block
      result =
        CachedDB.lngettext(
          "fr",
          "test_domain",
          "test_context",
          "One item",
          "%{count} items",
          5,
          %{}
        )

      assert result == {:ok, "5 éléments"}
    end

    test "returns error for non-existing translation" do
      result =
        CachedDB.lngettext(
          "fr",
          "test_domain",
          "test_context",
          "One thing",
          "%{count} things",
          5,
          %{}
        )

      assert result == {:error, :not_found}
    end

    test "correctly adds count to bindings", %{locale: locale, domain: domain} do
      # Create a specific message for this test
      {:ok, message} =
        Translations.create_message(%{
          message_type: :plural,
          msgid: "%{count} custom items with %{extra}",
          context_id: nil,
          domain_id: domain.id
        })

      {:ok, _translation_singular} =
        Translations.create_plural_translation(%{
          locale_id: locale.id,
          message_id: message.id,
          nplural_index: 0,
          translated_text: "%{count} élément personnalisé avec %{extra}"
        })

      {:ok, _translation_plural} =
        Translations.create_plural_translation(%{
          locale_id: locale.id,
          message_id: message.id,
          nplural_index: 1,
          translated_text: "%{count} éléments personnalisés avec %{extra}"
        })

      # Clear cache to ensure fresh state
      Kanta.Cache.delete_all()

      result =
        CachedDB.lngettext(
          "fr",
          "test_domain",
          nil,
          "One custom item with %{extra}",
          "%{count} custom items with %{extra}",
          3,
          %{extra: "info"}
        )

      assert result == {:ok, "3 éléments personnalisés avec info"}
    end
  end

  # Run after each test
  setup_all do
    on_exit(fn ->
      Kanta.Cache.delete_all()
    end)
  end
end
