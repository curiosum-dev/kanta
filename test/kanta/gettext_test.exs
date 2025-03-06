defmodule Kanta.GettextTest do
  # Some things change the :gettext app environment.
  use Kanta.Test.DataCase, async: false

  alias Kanta.Test.Backend

  setup_all do
    {:ok, locale_default} =
      with {:error, :locale, :not_found} <-
             Kanta.Translations.get_locale(filter: [iso639_code: "en"]) do
        Kanta.Translations.create_locale(%{
          iso639_code: "en",
          name: "English",
          native_name: "English"
        })
      end

    {:ok, locale_italian} =
      with {:error, :locale, :not_found} <-
             Kanta.Translations.get_locale(filter: [iso639_code: "it"]) do
        Kanta.Translations.create_locale(%{
          iso639_code: "it",
          name: "Italian",
          native_name: "Italiano",
          plurals_header: "nplurals=2; plural=(n != 1);"
        })
      end

    {:ok, domain_default} =
      with {:error, :domain, :not_found} <-
             Kanta.Translations.get_domain(filter: [name: "default"]) do
        Kanta.Translations.create_domain(%{name: "default"})
      end

    {:ok, domain_errors} =
      with {:error, :domain, :not_found} <-
             Kanta.Translations.get_domain(filter: [name: "errors"]) do
        Kanta.Translations.create_domain(%{name: "errors"})
      end

    %{
      locale_default: locale_default,
      locale_italian: locale_italian,
      domain_default: domain_default,
      domain_errors: domain_errors
    }
  end

  setup do
    # clears value set by &Gettext.put_locale/1
    Process.delete(Kanta.Gettext)

    :ok
  end

  describe "Kanta.Gettext" do
    test "uses PO file translation when no DB or cache entry exists, prefers DB translation over PO file translation",
         %{
           locale_italian: locale_italian,
           domain_default: domain_default
         } do
      use Kanta.Gettext, backend: Kanta.Test.Backend

      # Default locale (en) translation from PO file
      assert gettext("Hello world") == "Hello world"

      # Italian translation from PO file
      Gettext.put_locale("it")
      assert gettext("Hello world") == "Ciao mondo"

      {:ok, message} =
        Kanta.Translations.create_message(%{
          msgid: "Hello world",
          domain_id: domain_default.id,
          context_id: nil,
          application_source_id: nil,
          message_type: "singular"
        })

      {:ok, _} =
        Kanta.Translations.create_singular_translation(%{
          locale_id: locale_italian.id,
          message_id: message.id,
          translated_text: "Ciao dal database"
        })

      # Should use DB translation instead of PO file's "Ciao mondo"
      assert gettext("Hello world") == "Ciao dal database"
    end

    test "falls back to default locale when translation in PO file is missing" do
      use Kanta.Gettext, backend: Kanta.Test.Backend

      # Set to locale with no translation
      Gettext.put_locale("fr")

      # Should fall back to English (default) PO translation
      assert gettext("Hello world") == "Hello world"
    end

    test "falls back to default locale when translation in DB from current locale is nil", %{
      locale_default: locale_default,
      locale_italian: locale_italian,
      domain_default: domain_default
    } do
      use Kanta.Gettext, backend: Kanta.Test.Backend

      assert (Application.get_env(:kanta, :default_locale) || "en") == "en"

      # Create a message and its English (default locale) translation in DB
      {:ok, message} =
        Kanta.Translations.create_message(%{
          msgid: "Database fallback test",
          domain_id: domain_default.id,
          context_id: nil,
          application_source_id: nil,
          message_type: "singular"
        })

      {:ok, _} =
        Kanta.Translations.create_singular_translation(%{
          locale_id: locale_italian.id,
          message_id: message.id,
          translated_text: nil
        })

      {:ok, _} =
        Kanta.Translations.create_singular_translation(%{
          locale_id: locale_default.id,
          message_id: message.id,
          translated_text: "English DB translation"
        })

      # Set to locale with no translation
      Gettext.put_locale("it")

      # Should fall back to English DB translation
      assert gettext("Database fallback test") == "English DB translation"
    end

    test "properly handles bindings in singular translations", %{
      locale_italian: locale_italian,
      domain_default: domain_default
    } do
      use Kanta.Gettext, backend: Kanta.Test.Backend

      # Test interpolation with PO file translation
      Gettext.put_locale("it")
      assert pgettext("test", "Hello %{name}", name: "Mario") == "Ciao Mario"

      {:ok, context} = Kanta.Translations.get_context(filters: [name: "test"])

      # Create DB translation
      {:ok, message} =
        Kanta.Translations.create_message(%{
          msgid: "Hello %{name}",
          domain_id: domain_default.id,
          context_id: context.id,
          application_source_id: nil,
          message_type: "singular"
        })

      {:ok, _} =
        Kanta.Translations.create_singular_translation(%{
          locale_id: locale_italian.id,
          message_id: message.id,
          translated_text: "Buongiorno %{name}"
        })

      # Test interpolation with DB translation
      assert pgettext("test", "Hello %{name}", name: "Mario") == "Buongiorno Mario"
    end

    test "properly handles bindings in plural translations", %{
      locale_italian: locale_italian,
      domain_errors: domain_errors
    } do
      use Kanta.Gettext, backend: Kanta.Test.Backend

      Gettext.put_locale("it")

      # For missing translations, should fall back to PO file
      assert dngettext(
               "errors",
               "There was an error",
               "There were %{count} errors",
               1
             ) == "C'è stato un errore"

      assert dngettext(
               "errors",
               "There was an error",
               "There were %{count} errors",
               3
             ) == "Ci sono stati 3 errori"

      # Insert DB plural translation
      {:ok, message} =
        Kanta.Translations.create_message(%{
          msgid: "There were %{count} errors",
          domain_id: domain_errors.id,
          context_id: nil,
          application_source_id: nil,
          message_type: "plural"
        })

      {:ok, _} =
        Kanta.Translations.create_plural_translation(%{
          locale_id: locale_italian.id,
          message_id: message.id,
          nplural_index: 0,
          translated_text: "C'è stato un errore dal database"
        })

      {:ok, _} =
        Kanta.Translations.create_plural_translation(%{
          locale_id: locale_italian.id,
          message_id: message.id,
          nplural_index: 1,
          translated_text: "Ci sono stati %{count} errori dal database"
        })

      # Should use DB translation
      assert dngettext(
               "errors",
               "There was an error",
               "There were %{count} errors",
               1
             ) == "C'è stato un errore dal database"

      assert dngettext(
               "errors",
               "There was an error",
               "There were %{count} errors",
               3
             ) == "Ci sono stati 3 errori dal database"
    end
  end
end
