defmodule Kanta.GettextTest do
  use Kanta.Test.DataCase

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

    # clear cached translations
    Kanta.Cache.delete_all()

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

    test "handles contexts correctly", %{
      locale_italian: locale_italian,
      domain_default: domain_default
    } do
      use Kanta.Gettext, backend: Kanta.Test.Backend

      Gettext.put_locale("it")

      # Test with non-existent context
      assert pgettext("non-existent", "Hello") == "Hello"

      # Test with multiple contexts
      {:ok, context1} = Kanta.Translations.create_context(%{name: "context1"})
      {:ok, context2} = Kanta.Translations.create_context(%{name: "context2"})

      {:ok, message1} =
        Kanta.Translations.create_message(%{
          msgid: "Bank",
          domain_id: domain_default.id,
          context_id: context1.id,
          application_source_id: nil,
          message_type: "singular"
        })

      {:ok, message2} =
        Kanta.Translations.create_message(%{
          msgid: "Bank",
          domain_id: domain_default.id,
          context_id: context2.id,
          application_source_id: nil,
          message_type: "singular"
        })

      {:ok, _} =
        Kanta.Translations.create_singular_translation(%{
          locale_id: locale_italian.id,
          message_id: message1.id,
          # Financial institution
          translated_text: "Banca"
        })

      {:ok, _} =
        Kanta.Translations.create_singular_translation(%{
          locale_id: locale_italian.id,
          message_id: message2.id,
          # River bank
          translated_text: "Riva"
        })

      # Should get different translations based on context
      assert pgettext("context1", "Bank") == "Banca"
      assert pgettext("context2", "Bank") == "Riva"
    end

    test "handles domains correctly", %{
      locale_italian: locale_italian
    } do
      use Kanta.Gettext, backend: Kanta.Test.Backend

      Gettext.put_locale("it")

      # Test with non-existent domain
      assert dgettext("non-existent", "Hello") == "Hello"

      # Test with multiple domains
      {:ok, domain1} = Kanta.Translations.create_domain(%{name: "domain1"})
      {:ok, domain2} = Kanta.Translations.create_domain(%{name: "domain2"})

      {:ok, message1} =
        Kanta.Translations.create_message(%{
          msgid: "Message",
          domain_id: domain1.id,
          context_id: nil,
          application_source_id: nil,
          message_type: "singular"
        })

      {:ok, message2} =
        Kanta.Translations.create_message(%{
          msgid: "Message",
          domain_id: domain2.id,
          context_id: nil,
          application_source_id: nil,
          message_type: "singular"
        })

      {:ok, _} =
        Kanta.Translations.create_singular_translation(%{
          locale_id: locale_italian.id,
          message_id: message1.id,
          translated_text: "Messaggio 1"
        })

      {:ok, _} =
        Kanta.Translations.create_singular_translation(%{
          locale_id: locale_italian.id,
          message_id: message2.id,
          translated_text: "Messaggio 2"
        })

      # Should get different translations based on domain
      assert dgettext("domain1", "Message") == "Messaggio 1"
      assert dgettext("domain2", "Message") == "Messaggio 2"
    end

    test "handles complex plural rules correctly", %{
      domain_default: domain_default
    } do
      use Kanta.Gettext, backend: Kanta.Test.Backend

      # Create a locale with complex plural rules (e.g., Arabic)
      {:ok, locale_arabic} =
        Kanta.Translations.create_locale(%{
          iso639_code: "ar",
          name: "Arabic",
          native_name: "العربية",
          plurals_header:
            "nplurals=6; plural=(n==0 ? 0 : n==1 ? 1 : n==2 ? 2 : n%100>=3 && n%100<=10 ? 3 : n%100>=11 ? 4 : 5);"
        })

      {:ok, message} =
        Kanta.Translations.create_message(%{
          msgid: "%{count} files",
          domain_id: domain_default.id,
          context_id: nil,
          application_source_id: nil,
          message_type: "plural"
        })

      # Create translations for different plural forms
      Enum.each(0..5, fn index ->
        {:ok, _} =
          Kanta.Translations.create_plural_translation(%{
            locale_id: locale_arabic.id,
            message_id: message.id,
            nplural_index: index,
            translated_text: "form_#{index}"
          })
      end)

      Gettext.put_locale("ar")

      # Test different numbers to ensure they map to the correct plural forms
      assert dngettext("default", "file", "%{count} files", 0) == "form_0"
      assert dngettext("default", "file", "%{count} files", 1) == "form_1"
      assert dngettext("default", "file", "%{count} files", 2) == "form_2"
      assert dngettext("default", "file", "%{count} files", 3) == "form_3"
      assert dngettext("default", "file", "%{count} files", 11) == "form_4"
      assert dngettext("default", "file", "%{count} files", 101) == "form_5"
    end
  end
end
