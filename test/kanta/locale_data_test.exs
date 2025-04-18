defmodule Kanta.LocaleInfoTest do
  use ExUnit.Case, async: true

  alias Kanta.LocaleInfo, as: LocaleInfo

  describe "get_locale_info/1" do
    test "returns metadata for exact locale matches" do
      assert %LocaleInfo{
               language_name: "Portuguese",
               unicode_flag: "🇧🇷",
               flag_colors: ["#009B3A", "#FFCC29", "#002776"]
             } = LocaleInfo.get_locale_info("pt-br")
    end

    test "handles case insensitivity" do
      lowercase = LocaleInfo.get_locale_info("en-us")
      uppercase = LocaleInfo.get_locale_info("EN-US")
      mixed_case = LocaleInfo.get_locale_info("En-Us")

      assert lowercase == uppercase
      assert lowercase == mixed_case

      assert %LocaleInfo{
               language_name: "English",
               unicode_flag: "🇺🇸",
               flag_colors: ["#B22234", "#FFFFFF", "#3C3B6E"]
             } = lowercase
    end

    test "returns inherited data for base language codes" do
      assert %LocaleInfo{
               language_name: "Polish",
               unicode_flag: "🇵🇱",
               flag_colors: ["#FFFFFF", "#DC143C"]
             } = LocaleInfo.get_locale_info("pl")
    end

    test "returns partial data when some attributes have no fallback" do
      assert %LocaleInfo{
               language_name: "English",
               unicode_flag: nil,
               flag_colors: nil
             } = LocaleInfo.get_locale_info("en")
    end

    test "returns nil for unknown locales" do
      assert LocaleInfo.get_locale_info("xx-yy") == nil
      assert LocaleInfo.get_locale_info("not-a-locale") == nil
    end

    test "returns nil for non-string inputs" do
      assert LocaleInfo.get_locale_info(123) == nil
      assert LocaleInfo.get_locale_info(nil) == nil
      assert LocaleInfo.get_locale_info(%{}) == nil
      assert LocaleInfo.get_locale_info([]) == nil
    end

    test "correctly handles special cases" do
      # Latin American Spanish
      assert %LocaleInfo{
               language_name: "Latin American Spanish",
               unicode_flag: nil,
               flag_colors: nil
             } = LocaleInfo.get_locale_info("es-419")

      # Latin (historical language with no specific region)
      assert %LocaleInfo{
               language_name: "Latin",
               unicode_flag: nil,
               flag_colors: nil
             } = LocaleInfo.get_locale_info("la")
    end

    test "verifies consistent language names between base and regional variants" do
      # Sample checks of base language and regional variants
      assert LocaleInfo.get_locale_info("de").language_name ==
               LocaleInfo.get_locale_info("de-de").language_name

      assert LocaleInfo.get_locale_info("fr").language_name ==
               LocaleInfo.get_locale_info("fr-fr").language_name
    end

    test "properly handles languages with multiple regions" do
      # German has multiple regions
      de = LocaleInfo.get_locale_info("de")
      de_de = LocaleInfo.get_locale_info("de-de")
      de_at = LocaleInfo.get_locale_info("de-at")
      de_ch = LocaleInfo.get_locale_info("de-ch")

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
