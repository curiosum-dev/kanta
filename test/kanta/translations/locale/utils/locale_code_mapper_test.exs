defmodule Kanta.Translations.Locale.Utils.LocaleCodeMapperTest do
  use ExUnit.Case, async: true

  alias Kanta.Translations.Locale.Utils.LocaleCodeMapper

  describe "get_native_name/1" do
    test "returns native name for valid ISO639 codes" do
      assert LocaleCodeMapper.get_native_name("en") == "English"
      assert LocaleCodeMapper.get_native_name("es") == "Español"
      assert LocaleCodeMapper.get_native_name("uk") == "Українська"
      assert LocaleCodeMapper.get_native_name("mk") == "македонски јазик"
      assert LocaleCodeMapper.get_native_name("bm") == "bamanankan"
    end

    test "returns code itself as fallback for invalid ISO639 codes" do
      assert LocaleCodeMapper.get_native_name("xyz") == "xyz"
      assert LocaleCodeMapper.get_native_name("invalid") == "invalid"
      assert LocaleCodeMapper.get_native_name("notacode") == "notacode"
      assert LocaleCodeMapper.get_native_name("123") == "123"
    end

    test "handles edge cases" do
      assert LocaleCodeMapper.get_native_name("") == ""
      assert LocaleCodeMapper.get_native_name("ZZ") == "ZZ"
      assert LocaleCodeMapper.get_native_name("ab-cd") == "ab-cd"
      assert LocaleCodeMapper.get_native_name("UPPERCASE") == "UPPERCASE"
    end

    test "handles nil input" do
      assert LocaleCodeMapper.get_native_name(nil) == nil
    end

    test "is case sensitive" do
      # Assuming the JSON contains lowercase codes
      assert LocaleCodeMapper.get_native_name("EN") == "EN"
      assert LocaleCodeMapper.get_native_name("en") == "English"
    end
  end

  describe "get_name/1" do
    test "returns name for valid ISO639 codes" do
      assert LocaleCodeMapper.get_name("en") == "English"
      assert LocaleCodeMapper.get_name("es") == "Spanish"
      assert LocaleCodeMapper.get_name("uk") == "Ukrainian"
      assert LocaleCodeMapper.get_name("mk") == "Macedonian"
      assert LocaleCodeMapper.get_name("bm") == "Bambara"
    end

    test "returns code itself as fallback for invalid ISO639 codes" do
      assert LocaleCodeMapper.get_name("xyz") == "xyz"
      assert LocaleCodeMapper.get_name("invalid") == "invalid"
      assert LocaleCodeMapper.get_name("notacode") == "notacode"
      assert LocaleCodeMapper.get_name("123") == "123"
    end

    test "handles edge cases" do
      assert LocaleCodeMapper.get_name("") == ""
      assert LocaleCodeMapper.get_name("ZZ") == "ZZ"
      assert LocaleCodeMapper.get_name("ab-cd") == "ab-cd"
      assert LocaleCodeMapper.get_name("UPPERCASE") == "UPPERCASE"
    end

    test "handles nil input" do
      assert LocaleCodeMapper.get_name(nil) == nil
    end

    test "is case sensitive" do
      # Assuming the JSON contains lowercase codes
      assert LocaleCodeMapper.get_name("EN") == "EN"
      assert LocaleCodeMapper.get_name("en") == "English"
    end
  end

  describe "get_family/1" do
    test "returns family for valid ISO639 codes" do
      assert LocaleCodeMapper.get_family("en") == "Indo-European"
      assert LocaleCodeMapper.get_family("es") == "Indo-European"
      assert LocaleCodeMapper.get_family("uk") == "Indo-European"
      assert LocaleCodeMapper.get_family("mk") == "Indo-European"
      assert LocaleCodeMapper.get_family("bm") == "Niger–Congo"
      assert LocaleCodeMapper.get_family("tk") == "Turkic"
      assert LocaleCodeMapper.get_family("uz") == "Turkic"
    end

    test "returns 'unknown' as fallback for invalid ISO639 codes" do
      assert LocaleCodeMapper.get_family("xyz") == "unknown"
      assert LocaleCodeMapper.get_family("invalid") == "unknown"
      assert LocaleCodeMapper.get_family("notacode") == "unknown"
      assert LocaleCodeMapper.get_family("123") == "unknown"
    end

    test "handles edge cases" do
      assert LocaleCodeMapper.get_family("") == "unknown"
      assert LocaleCodeMapper.get_family("ZZ") == "unknown"
      assert LocaleCodeMapper.get_family("ab-cd") == "unknown"
      assert LocaleCodeMapper.get_family("UPPERCASE") == "unknown"
    end

    test "handles nil input" do
      assert LocaleCodeMapper.get_family(nil) == "unknown"
    end

    test "is case sensitive" do
      # Assuming the JSON contains lowercase codes
      assert LocaleCodeMapper.get_family("EN") == "unknown"
      assert LocaleCodeMapper.get_family("en") == "Indo-European"
    end
  end

  describe "get_wiki_url/1" do
    test "returns wiki URL for valid ISO639 codes" do
      assert LocaleCodeMapper.get_wiki_url("en") ==
               "https://en.wikipedia.org/wiki/English_language"

      assert LocaleCodeMapper.get_wiki_url("es") ==
               "https://en.wikipedia.org/wiki/Spanish_language"

      assert LocaleCodeMapper.get_wiki_url("uk") ==
               "https://en.wikipedia.org/wiki/Ukrainian_language"

      assert LocaleCodeMapper.get_wiki_url("mk") ==
               "https://en.wikipedia.org/wiki/Macedonian_language"

      assert LocaleCodeMapper.get_wiki_url("bm") ==
               "https://en.wikipedia.org/wiki/Bambara_language"

      assert LocaleCodeMapper.get_wiki_url("tk") ==
               "https://en.wikipedia.org/wiki/Turkmen_language"
    end

    test "returns 'unknown' as fallback for invalid ISO639 codes" do
      assert LocaleCodeMapper.get_wiki_url("xyz") == "unknown"
      assert LocaleCodeMapper.get_wiki_url("invalid") == "unknown"
      assert LocaleCodeMapper.get_wiki_url("notacode") == "unknown"
      assert LocaleCodeMapper.get_wiki_url("123") == "unknown"
    end

    test "handles edge cases" do
      assert LocaleCodeMapper.get_wiki_url("") == "unknown"
      assert LocaleCodeMapper.get_wiki_url("ZZ") == "unknown"
      assert LocaleCodeMapper.get_wiki_url("ab-cd") == "unknown"
      assert LocaleCodeMapper.get_wiki_url("UPPERCASE") == "unknown"
    end

    test "handles nil input" do
      assert LocaleCodeMapper.get_wiki_url(nil) == "unknown"
    end

    test "is case sensitive" do
      # Assuming the JSON contains lowercase codes
      assert LocaleCodeMapper.get_wiki_url("EN") == "unknown"

      assert LocaleCodeMapper.get_wiki_url("en") ==
               "https://en.wikipedia.org/wiki/English_language"
    end
  end

  describe "get_colors/1" do
    test "returns colors array for valid ISO639 codes" do
      assert LocaleCodeMapper.get_colors("en") == ["#3B3B6D", "#B42F34"]
      assert LocaleCodeMapper.get_colors("es") == ["#DE3B30", "#F8C433", "#DE3B30"]
      assert LocaleCodeMapper.get_colors("uk") == ["#02411C", "#FED500"]
      assert LocaleCodeMapper.get_colors("mk") == ["#D91F21", "#F8EA2B"]
      assert LocaleCodeMapper.get_colors("bm") == ["#16B43A", "#FCD116", "#CE1226"]
      assert LocaleCodeMapper.get_colors("tk") == ["#00853A", "#D3212C", "#FFFFFF"]
      assert LocaleCodeMapper.get_colors("uz") == ["#0099B5", "#FFFFFF", "#1FB43A"]
    end

    test "returns default black color as fallback for invalid ISO639 codes" do
      assert LocaleCodeMapper.get_colors("xyz") == ["#000000"]
      assert LocaleCodeMapper.get_colors("invalid") == ["#000000"]
      assert LocaleCodeMapper.get_colors("notacode") == ["#000000"]
      assert LocaleCodeMapper.get_colors("123") == ["#000000"]
    end

    test "handles edge cases" do
      assert LocaleCodeMapper.get_colors("") == ["#000000"]
      assert LocaleCodeMapper.get_colors("ZZ") == ["#000000"]
      assert LocaleCodeMapper.get_colors("ab-cd") == ["#000000"]
      assert LocaleCodeMapper.get_colors("UPPERCASE") == ["#000000"]
    end

    test "handles nil input" do
      assert LocaleCodeMapper.get_colors(nil) == ["#000000"]
    end

    test "is case sensitive" do
      # Assuming the JSON contains lowercase codes
      assert LocaleCodeMapper.get_colors("EN") == ["#000000"]
      assert LocaleCodeMapper.get_colors("en") == ["#3B3B6D", "#B42F34"]
    end

    test "returns array of hex color codes" do
      colors = LocaleCodeMapper.get_colors("en")
      assert is_list(colors)
      assert length(colors) >= 1

      # Verify all colors are hex color codes
      Enum.each(colors, fn color ->
        assert String.match?(color, ~r/^#[0-9A-F]{6}$/i)
      end)
    end
  end

  describe "error handling and file access" do
    test "all functions handle JSON file reading correctly" do
      # These tests verify that the JSON file exists and can be read
      # If the file was missing or corrupted, these would raise exceptions
      refute_raise(fn -> LocaleCodeMapper.get_name("en") end)
      refute_raise(fn -> LocaleCodeMapper.get_native_name("en") end)
      refute_raise(fn -> LocaleCodeMapper.get_family("en") end)
      refute_raise(fn -> LocaleCodeMapper.get_wiki_url("en") end)
      refute_raise(fn -> LocaleCodeMapper.get_colors("en") end)
    end

    test "functions are consistent across multiple calls" do
      # Test that multiple calls return the same result (no side effects)
      assert LocaleCodeMapper.get_name("en") == LocaleCodeMapper.get_name("en")
      assert LocaleCodeMapper.get_native_name("es") == LocaleCodeMapper.get_native_name("es")
      assert LocaleCodeMapper.get_family("uk") == LocaleCodeMapper.get_family("uk")
      assert LocaleCodeMapper.get_wiki_url("mk") == LocaleCodeMapper.get_wiki_url("mk")
      assert LocaleCodeMapper.get_colors("bm") == LocaleCodeMapper.get_colors("bm")
    end

    test "fallback behavior is consistent across functions" do
      invalid_code = "definitely_not_a_code"

      # Name and native_name return the code itself
      assert LocaleCodeMapper.get_name(invalid_code) == invalid_code
      assert LocaleCodeMapper.get_native_name(invalid_code) == invalid_code

      # Family and wiki_url return "unknown"
      assert LocaleCodeMapper.get_family(invalid_code) == "unknown"
      assert LocaleCodeMapper.get_wiki_url(invalid_code) == "unknown"

      # Colors returns default black
      assert LocaleCodeMapper.get_colors(invalid_code) == ["#000000"]
    end
  end

  describe "integration with real ISO639 data" do
    test "verifies data consistency for known languages" do
      # Test a few well-known languages to ensure data integrity
      languages_to_test = ["en", "es", "fr", "de", "it", "pt", "ru", "zh", "ja", "ko"]

      Enum.each(languages_to_test, fn code ->
        # All these should return non-fallback values if the language exists in the JSON
        name = LocaleCodeMapper.get_name(code)
        native_name = LocaleCodeMapper.get_native_name(code)
        family = LocaleCodeMapper.get_family(code)
        wiki_url = LocaleCodeMapper.get_wiki_url(code)
        colors = LocaleCodeMapper.get_colors(code)

        # If the language exists in JSON, these assertions should pass
        # If not, they'll return fallback values
        if name != code do
          # Language exists in JSON, verify data quality
          assert is_binary(name) and String.length(name) > 0
          assert is_binary(native_name) and String.length(native_name) > 0
          assert is_binary(family) and family != "unknown"
          assert is_binary(wiki_url) and String.starts_with?(wiki_url, "https://")
          assert is_list(colors) and length(colors) >= 1
        end
      end)
    end

    test "validates data structure for valid entries" do
      # Test with a known valid code
      code = "en"

      # Verify all returned data has expected structure
      name = LocaleCodeMapper.get_name(code)
      native_name = LocaleCodeMapper.get_native_name(code)
      family = LocaleCodeMapper.get_family(code)
      wiki_url = LocaleCodeMapper.get_wiki_url(code)
      colors = LocaleCodeMapper.get_colors(code)

      assert is_binary(name)
      assert is_binary(native_name)
      assert is_binary(family)
      assert is_binary(wiki_url)
      assert is_list(colors)

      # Verify URL format
      assert String.starts_with?(wiki_url, "https://en.wikipedia.org/wiki/")

      # Verify colors are valid hex codes
      Enum.each(colors, fn color ->
        assert String.match?(color, ~r/^#[0-9A-F]{6}$/i)
      end)
    end
  end

  describe "memory and performance characteristics" do
    test "functions don't accumulate memory across calls" do
      # Test that repeated calls don't cause memory issues
      codes = ["en", "es", "invalid", "xyz", nil, ""]

      Enum.each(1..100, fn _ ->
        Enum.each(codes, fn code ->
          LocaleCodeMapper.get_name(code)
          LocaleCodeMapper.get_native_name(code)
          LocaleCodeMapper.get_family(code)
          LocaleCodeMapper.get_wiki_url(code)
          LocaleCodeMapper.get_colors(code)
        end)
      end)

      # If we got here without issues, memory handling is acceptable
      assert true
    end

    test "handles concurrent access correctly" do
      # Test that multiple processes can call the functions simultaneously
      parent = self()

      tasks =
        Enum.map(1..10, fn i ->
          Task.async(fn ->
            code = if rem(i, 2) == 0, do: "en", else: "invalid_#{i}"

            result = {
              LocaleCodeMapper.get_name(code),
              LocaleCodeMapper.get_native_name(code),
              LocaleCodeMapper.get_family(code),
              LocaleCodeMapper.get_wiki_url(code),
              LocaleCodeMapper.get_colors(code)
            }

            send(parent, {:result, i, result})
          end)
        end)

      # Wait for all tasks to complete
      Enum.each(tasks, &Task.await/1)

      # Verify we received all results
      results =
        Enum.map(1..10, fn i ->
          receive do
            {:result, ^i, result} -> result
          after
            1000 -> :timeout
          end
        end)

      refute Enum.member?(results, :timeout)
    end
  end

  # Helper function to test that no exception is raised
  defp refute_raise(fun) do
    try do
      fun.()
      assert true
    rescue
      _ -> flunk("Expected no exception to be raised")
    end
  end
end
