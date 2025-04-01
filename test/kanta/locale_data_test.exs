defmodule Kanta.LocaleDataTest do
  use ExUnit.Case, async: true

  alias Kanta.LocaleData, as: LocaleData
  alias Kanta.LocaleData.Metadata, as: Metadata

  describe "get_locale_metadata/1" do
    test "returns metadata for exact locale matches" do
      assert %Metadata{
               language_name: "Portuguese",
               unicode_flag: "🇧🇷",
               flag_colors: ["#009B3A", "#FFCC29", "#002776"]
             } = LocaleData.get_locale_metadata("pt-br")
    end

    test "handles case insensitivity" do
      lowercase = LocaleData.get_locale_metadata("en-us")
      uppercase = LocaleData.get_locale_metadata("EN-US")
      mixed_case = LocaleData.get_locale_metadata("En-Us")

      assert lowercase == uppercase
      assert lowercase == mixed_case

      assert %Metadata{
               language_name: "English",
               unicode_flag: "🇺🇸",
               flag_colors: ["#B22234", "#FFFFFF", "#3C3B6E"]
             } = lowercase
    end

    test "returns inherited data for base language codes" do
      assert %Metadata{
               language_name: "Polish",
               unicode_flag: "🇵🇱",
               flag_colors: ["#FFFFFF", "#DC143C"]
             } = LocaleData.get_locale_metadata("pl")
    end

    test "returns partial data when some attributes have no fallback" do
      assert %Metadata{
               language_name: "English",
               unicode_flag: nil,
               flag_colors: nil
             } = LocaleData.get_locale_metadata("en")
    end

    test "returns nil for unknown locales" do
      assert LocaleData.get_locale_metadata("xx-yy") == nil
      assert LocaleData.get_locale_metadata("not-a-locale") == nil
    end

    test "returns nil for non-string inputs" do
      assert LocaleData.get_locale_metadata(123) == nil
      assert LocaleData.get_locale_metadata(nil) == nil
      assert LocaleData.get_locale_metadata(%{}) == nil
      assert LocaleData.get_locale_metadata([]) == nil
    end

    test "correctly handles special cases" do
      # Latin American Spanish
      assert %Metadata{
               language_name: "Latin American Spanish",
               unicode_flag: nil,
               flag_colors: nil
             } = LocaleData.get_locale_metadata("es-419")

      # Latin (historical language with no specific region)
      assert %Metadata{
               language_name: "Latin",
               unicode_flag: nil,
               flag_colors: nil
             } = LocaleData.get_locale_metadata("la")
    end

    test "verifies consistent language names between base and regional variants" do
      # Sample checks of base language and regional variants
      assert LocaleData.get_locale_metadata("de").language_name ==
               LocaleData.get_locale_metadata("de-de").language_name

      assert LocaleData.get_locale_metadata("fr").language_name ==
               LocaleData.get_locale_metadata("fr-fr").language_name
    end

    test "properly handles languages with multiple regions" do
      # German has multiple regions
      de = LocaleData.get_locale_metadata("de")
      de_de = LocaleData.get_locale_metadata("de-de")
      de_at = LocaleData.get_locale_metadata("de-at")
      de_ch = LocaleData.get_locale_metadata("de-ch")

      assert de.language_name == "German"
      assert de_de.language_name == "German"
      assert de_at.language_name == "German"
      assert de_ch.language_name == "German"

      # But flags and colors differ
      assert de.unicode_flag == "🇩🇪"
      assert de_de.unicode_flag == "🇩🇪"
      assert de_at.unicode_flag == "🇦🇹"
      assert de_ch.unicode_flag == "🇨🇭"
    end
  end
end
