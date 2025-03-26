defmodule Kanta.BackendTest do
  require Logger
  use Kanta.Test.DataCase, async: false

  alias Kanta.Translations

  defmodule Backend do
    use Kanta.Backend, otp_app: :kanta, priv: "test/fixtures/single_messages"
  end

  alias Kanta.BackendTest.Backend

  setup do
    # Clear the cache before each test
    Kanta.Cache.delete_all()

    # Create test data in database
    {:ok, locale} =
      Translations.create_locale(%{
        native_name: "Italiano",
        name: "Italian",
        iso639_code: "it",
        plurals_header: "nplurals=2; plural=(n != 1);"
      })

    {:ok, domain} = Translations.create_domain(%{name: "default"})
    {:ok, context} = Translations.create_context(%{name: "test"})

    # Create messages and translations for database-backed tests

    # 1. Message for DB test with no PO equivalent
    {:ok, db_only_message} =
      Translations.create_message(%{
        message_type: :singular,
        msgid: "DB only message",
        context_id: context.id,
        domain_id: domain.id
      })

    {:ok, _db_only_translation} =
      Translations.create_singular_translation(%{
        locale_id: locale.id,
        message_id: db_only_message.id,
        translated_text: "Messaggio solo nel DB"
      })

    # 2. Message that exists in both DB and PO to test priority
    {:ok, override_message} =
      Translations.create_message(%{
        message_type: :singular,
        msgid: "Hello world",
        context_id: context.id,
        domain_id: domain.id
      })

    {:ok, _override_translation} =
      Translations.create_singular_translation(%{
        locale_id: locale.id,
        message_id: override_message.id,
        translated_text: "DB: Ciao mondo"
      })

    # 3. Plural message in DB
    {:ok, plural_message} =
      Translations.create_message(%{
        message_type: :plural,
        msgid: "%{count} plural messages",
        context_id: context.id,
        domain_id: domain.id
      })

    # Create plural translations for both forms
    {:ok, _plural_translation_one} =
      Translations.create_plural_translation(%{
        locale_id: locale.id,
        message_id: plural_message.id,
        nplural_index: 0,
        translated_text: "DB: %{count} messaggio plurale"
      })

    {:ok, _plural_translation_many} =
      Translations.create_plural_translation(%{
        locale_id: locale.id,
        message_id: plural_message.id,
        nplural_index: 1,
        translated_text: "DB: %{count} messaggi plurali"
      })

    # 4. Override plural message that exists in PO
    {:ok, override_plural_message} =
      Translations.create_message(%{
        message_type: :plural,
        msgid: "%{count} new emails",
        context_id: nil,
        domain_id: domain.id
      })

    {:ok, _override_plural_singular} =
      Translations.create_plural_translation(%{
        locale_id: locale.id,
        message_id: override_plural_message.id,
        nplural_index: 0,
        translated_text: "DB: Una nuova email"
      })

    {:ok, _override_plural_plural} =
      Translations.create_plural_translation(%{
        locale_id: locale.id,
        message_id: override_plural_message.id,
        nplural_index: 1,
        translated_text: "DB: %{count} nuove email"
      })

    :ok
  end

  describe "Database-backed translations" do
    test "translates messages that only exist in DB" do
      Gettext.put_locale("it")

      assert Gettext.dpgettext(Backend, "default", "test", "DB only message", %{}) ==
               "Messaggio solo nel DB"
    end

    test "DB translations take priority over PO file translations" do
      # This should use the DB version which overrides the PO file version

      Gettext.with_locale("it", fn ->
        assert Gettext.dpgettext(Backend, "default", "test", "Hello world", %{}) ==
                 "DB: Ciao mondo"
      end)
    end

    test "translates plural forms from DB" do
      Gettext.put_locale("it")

      assert Gettext.dpngettext(
               Backend,
               "default",
               "test",
               "DB plural message",
               "%{count} plural messages",
               1,
               %{}
             ) ==
               "DB: 1 messaggio plurale"

      assert Gettext.dpngettext(
               Backend,
               "default",
               "test",
               "DB plural message",
               "%{count} plural messages",
               5,
               %{}
             ) ==
               "DB: 5 messaggi plurali"
    end

    test "DB plural translations override PO plural translations" do
      # These should use the DB versions which override the PO file versions
      Gettext.put_locale("it")

      assert Gettext.dpngettext(
               Backend,
               "default",
               nil,
               "One new email",
               "%{count} new emails",
               1,
               %{}
             ) ==
               "DB: Una nuova email"

      assert Gettext.dpngettext(
               Backend,
               "default",
               nil,
               "One new email",
               "%{count} new emails",
               5,
               %{}
             ) ==
               "DB: 5 nuove email"
    end
  end

  describe "Fallback translations" do
    test "fallback to Gettext for simple translation" do
      Gettext.put_locale("it")
      # Test for a message that only exists in PO file
      assert Gettext.dpgettext(Backend, "default", "test", "Hello %{name}", %{name: "Kuba"}) ==
               "Ciao Kuba"
    end

    test "fallback for Gettext for plurals" do
      # Create a new message key not in the DB
      Gettext.put_locale("it")

      assert Gettext.dpngettext(Backend, "default", nil, "One apple", "%{count} apples", 1, %{}) ==
               "Una mela"

      assert Gettext.dpngettext(Backend, "default", nil, "One apple", "%{count} apples", 2, %{}) ==
               "2 mele"
    end
  end

  test "handles missing translations gracefully" do
    Gettext.put_locale("it")
    # Test what happens with a locale that doesn't exist anywhere
    assert Gettext.gettext(Backend, "Non-existent message") == "Non-existent message"

    # Test with a non-existent locale
    assert Gettext.with_locale("xy", fn ->
             Gettext.gettext(Backend, "Hello world")
           end) == "Hello world"
  end

  test "interpolates variables in both DB and PO translations" do
    # Add a new DB translation with variables
    {:ok, locale} = Translations.get_locale(filter: [iso639_code: "it"])
    {:ok, domain} = Translations.get_domain(filter: [name: "default"])

    {:ok, message} =
      Translations.create_message(%{
        message_type: :singular,
        msgid: "Welcome %{user} to %{app}",
        context_id: nil,
        domain_id: domain.id
      })

    {:ok, _translation} =
      Translations.create_singular_translation(%{
        locale_id: locale.id,
        message_id: message.id,
        translated_text: "Benvenuto %{user} a %{app}"
      })

    # Clear cache
    Kanta.Cache.delete_all()

    Gettext.put_locale("it")

    assert Gettext.gettext(Backend, "Welcome %{user} to %{app}", %{
             user: "Mario",
             app: "Kanta"
           }) ==
             "Benvenuto Mario a Kanta"
  end

  test "works with dynamic module API too" do
    # Test the functions available through the Gettext API

    Gettext.with_locale("it", fn ->
      assert Gettext.gettext(Backend, "Hello world") == "DB: Ciao mondo"

      assert Gettext.ngettext(Backend, "One new email", "%{count} new emails", 3) ==
               "DB: 3 nuove email"
    end)
  end
end
