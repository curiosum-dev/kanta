# kanta/lib/kanta/locale_data.ex
defmodule Kanta.LocaleInfo.Data do
  @moduledoc """
  Provides metadata for known locales based on IETF BCP 47 standards.
  Uses a pre-compiled static map for fast lookups. Base language codes
  (e.g., "pl") will inherit the flag/colors from their default regional
  variant (e.g., "pl-pl") if available and no specific region is defined
  for the base code.
  """

  # Raw data map
  @raw_locale_data %{
    # No af-af defined, stays nil
    "af" => {"Afrikaans", nil, nil},
    "af-za" =>
      {"Afrikaans", "🇿🇦", ["#E03C31", "#FFFFFF", "#007749", "#000000", "#FFB81C", "#001489"]},
    # No ar-ar defined, stays nil
    "ar" => {"Arabic", nil, nil},
    "ar-ae" => {"Arabic", "🇦🇪", ["#FF0000", "#00732F", "#FFFFFF", "#000000"]},
    "ar-sa" => {"Arabic", "🇸🇦", ["#006C35", "#FFFFFF"]},
    # Inherited from az-az
    "az" => {"Azerbaijani", "🇦🇿", ["#0092BC", "#E40000", "#3F9C35", "#FFFFFF"]},
    "az-az" => {"Azerbaijani", "🇦🇿", ["#0092BC", "#E40000", "#3F9C35", "#FFFFFF"]},
    # Inherited from be-by
    "be" => {"Belarusian", "🇧🇾", ["#CC0000", "#007A00", "#FFFFFF"]},
    "be-by" => {"Belarusian", "🇧🇾", ["#CC0000", "#007A00", "#FFFFFF"]},
    # Inherited from bg-bg
    "bg" => {"Bulgarian", "🇧🇬", ["#FFFFFF", "#00966E", "#D62612"]},
    "bg-bg" => {"Bulgarian", "🇧🇬", ["#FFFFFF", "#00966E", "#D62612"]},
    # Inherited from bn-bd
    "bn" => {"Bengali", "🇧🇩", ["#006A4E", "#F42A41"]},
    "bn-bd" => {"Bengali", "🇧🇩", ["#006A4E", "#F42A41"]},
    # Inherited from bs-ba
    "bs" => {"Bosnian", "🇧🇦", ["#002395", "#FFCD00", "#FFFFFF"]},
    "bs-ba" => {"Bosnian", "🇧🇦", ["#002395", "#FFCD00", "#FFFFFF"]},
    # Inherited from ca-es
    "ca" => {"Catalan", "🇪🇸", ["#AA151B", "#F1BF00"]},
    "ca-es" => {"Catalan", "🇪🇸", ["#AA151B", "#F1BF00"]},
    # Inherited from cs-cz
    "cs" => {"Czech", "🇨🇿", ["#FFFFFF", "#D7141A", "#11457E"]},
    "cs-cz" => {"Czech", "🇨🇿", ["#FFFFFF", "#D7141A", "#11457E"]},
    # Inherited from cy-gb
    "cy" => {"Welsh", "🇬🇧", ["#012169", "#FFFFFF", "#C8102E"]},
    "cy-gb" => {"Welsh", "🇬🇧", ["#012169", "#FFFFFF", "#C8102E"]},
    # Inherited from da-dk
    "da" => {"Danish", "🇩🇰", ["#C60C30", "#FFFFFF"]},
    "da-dk" => {"Danish", "🇩🇰", ["#C60C30", "#FFFFFF"]},
    # Inherited from de-de
    "de" => {"German", "🇩🇪", ["#000000", "#FF0000", "#FFCC00"]},
    "de-at" => {"German", "🇦🇹", ["#ED2939", "#FFFFFF"]},
    "de-ch" => {"German", "🇨🇭", ["#FF0000", "#FFFFFF"]},
    "de-de" => {"German", "🇩🇪", ["#000000", "#FF0000", "#FFCC00"]},
    # Inherited from el-gr
    "el" => {"Greek", "🇬🇷", ["#0D5EAF", "#FFFFFF"]},
    "el-gr" => {"Greek", "🇬🇷", ["#0D5EAF", "#FFFFFF"]},
    # No single default like en-en, stays nil
    "en" => {"English", nil, nil},
    "en-au" => {"English", "🇦🇺", ["#00008B", "#FFFFFF", "#FF0000"]},
    "en-ca" => {"English", "🇨🇦", ["#FF0000", "#FFFFFF"]},
    "en-gb" => {"English", "🇬🇧", ["#012169", "#FFFFFF", "#C8102E"]},
    "en-ie" => {"English", "🇮🇪", ["#009A49", "#FFFFFF", "#FF7900"]},
    "en-in" => {"English", "🇮🇳", ["#FF9933", "#FFFFFF", "#138808", "#000080"]},
    "en-nz" => {"English", "🇳🇿", ["#00247D", "#FFFFFF", "#CC142E"]},
    "en-us" => {"English", "🇺🇸", ["#B22234", "#FFFFFF", "#3C3B6E"]},
    "en-za" =>
      {"English", "🇿🇦", ["#E03C31", "#FFFFFF", "#007749", "#000000", "#FFB81C", "#001489"]},
    "eo" => {"Esperanto", nil, nil},
    # Inherited from es-es
    "es" => {"Spanish", "🇪🇸", ["#AA151B", "#F1BF00"]},
    "es-ar" => {"Spanish", "🇦🇷", ["#74ACDF", "#FFFFFF", "#F6B40E"]},
    "es-cl" => {"Spanish", "🇨🇱", ["#FFFFFF", "#0039A6", "#D52B1E"]},
    "es-co" => {"Spanish", "🇨🇴", ["#FCD116", "#003893", "#CE1126"]},
    "es-es" => {"Spanish", "🇪🇸", ["#AA151B", "#F1BF00"]},
    "es-mx" => {"Spanish", "🇲🇽", ["#006847", "#FFFFFF", "#CE1126"]},
    "es-us" => {"Spanish", "🇺🇸", ["#B22234", "#FFFFFF", "#3C3B6E"]},
    # Special case, no change
    "es-419" => {"Latin American Spanish", nil, nil},
    # Inherited from et-ee
    "et" => {"Estonian", "🇪🇪", ["#0072CE", "#000000", "#FFFFFF"]},
    "et-ee" => {"Estonian", "🇪🇪", ["#0072CE", "#000000", "#FFFFFF"]},
    # Inherited from eu-es
    "eu" => {"Basque", "🇪🇸", ["#AA151B", "#F1BF00"]},
    "eu-es" => {"Basque", "🇪🇸", ["#AA151B", "#F1BF00"]},
    # Inherited from fa-ir
    "fa" => {"Persian", "🇮🇷", ["#239F40", "#FFFFFF", "#DA0000"]},
    "fa-ir" => {"Persian", "🇮🇷", ["#239F40", "#FFFFFF", "#DA0000"]},
    # Inherited from fi-fi
    "fi" => {"Finnish", "🇫🇮", ["#FFFFFF", "#003580"]},
    "fi-fi" => {"Finnish", "🇫🇮", ["#FFFFFF", "#003580"]},
    # Inherited from fo-fo
    "fo" => {"Faroese", "🇫🇴", ["#FFFFFF", "#003897", "#ED2939"]},
    "fo-fo" => {"Faroese", "🇫🇴", ["#FFFFFF", "#003897", "#ED2939"]},
    # Inherited from fr-fr
    "fr" => {"French", "🇫🇷", ["#002395", "#FFFFFF", "#ED2939"]},
    "fr-be" => {"French", "🇧🇪", ["#000000", "#FAE042", "#ED2939"]},
    "fr-ca" => {"French", "🇨🇦", ["#FF0000", "#FFFFFF"]},
    "fr-ch" => {"French", "🇨🇭", ["#FF0000", "#FFFFFF"]},
    "fr-fr" => {"French", "🇫🇷", ["#002395", "#FFFFFF", "#ED2939"]},
    # Inherited from ga-ie
    "ga" => {"Irish", "🇮🇪", ["#009A49", "#FFFFFF", "#FF7900"]},
    "ga-ie" => {"Irish", "🇮🇪", ["#009A49", "#FFFFFF", "#FF7900"]},
    # Inherited from gl-es
    "gl" => {"Galician", "🇪🇸", ["#AA151B", "#F1BF00"]},
    "gl-es" => {"Galician", "🇪🇸", ["#AA151B", "#F1BF00"]},
    # Inherited from he-il
    "he" => {"Hebrew", "🇮🇱", ["#FFFFFF", "#0038B8"]},
    "he-il" => {"Hebrew", "🇮🇱", ["#FFFFFF", "#0038B8"]},
    # Inherited from hi-in
    "hi" => {"Hindi", "🇮🇳", ["#FF9933", "#FFFFFF", "#138808", "#000080"]},
    "hi-in" => {"Hindi", "🇮🇳", ["#FF9933", "#FFFFFF", "#138808", "#000080"]},
    # Inherited from hr-hr
    "hr" => {"Croatian", "🇭🇷", ["#FF0000", "#FFFFFF", "#0000FF"]},
    "hr-hr" => {"Croatian", "🇭🇷", ["#FF0000", "#FFFFFF", "#0000FF"]},
    # Inherited from hu-hu
    "hu" => {"Hungarian", "🇭🇺", ["#CE2939", "#FFFFFF", "#477050"]},
    "hu-hu" => {"Hungarian", "🇭🇺", ["#CE2939", "#FFFFFF", "#477050"]},
    # Inherited from hy-am
    "hy" => {"Armenian", "🇦🇲", ["#D90012", "#0033A0", "#F2A800"]},
    "hy-am" => {"Armenian", "🇦🇲", ["#D90012", "#0033A0", "#F2A800"]},
    # Inherited from id-id
    "id" => {"Indonesian", "🇮🇩", ["#FF0000", "#FFFFFF"]},
    "id-id" => {"Indonesian", "🇮🇩", ["#FF0000", "#FFFFFF"]},
    # Inherited from is-is
    "is" => {"Icelandic", "🇮🇸", ["#02529C", "#FFFFFF", "#DC1E35"]},
    "is-is" => {"Icelandic", "🇮🇸", ["#02529C", "#FFFFFF", "#DC1E35"]},
    # Inherited from it-it
    "it" => {"Italian", "🇮🇹", ["#009246", "#FFFFFF", "#CE2B37"]},
    "it-ch" => {"Italian", "🇨🇭", ["#FF0000", "#FFFFFF"]},
    "it-it" => {"Italian", "🇮🇹", ["#009246", "#FFFFFF", "#CE2B37"]},
    # Inherited from ja-jp
    "ja" => {"Japanese", "🇯🇵", ["#FFFFFF", "#BC002D"]},
    "ja-jp" => {"Japanese", "🇯🇵", ["#FFFFFF", "#BC002D"]},
    # Inherited from ka-ge
    "ka" => {"Georgian", "🇬🇪", ["#FFFFFF", "#FF0000"]},
    "ka-ge" => {"Georgian", "🇬🇪", ["#FFFFFF", "#FF0000"]},
    # Inherited from kk-kz
    "kk" => {"Kazakh", "🇰🇿", ["#00AFCA", "#FDE700"]},
    "kk-kz" => {"Kazakh", "🇰🇿", ["#00AFCA", "#FDE700"]},
    # Inherited from ko-kr
    "ko" => {"Korean", "🇰🇷", ["#FFFFFF", "#CD2E3A", "#0047A0", "#000000"]},
    "ko-kr" => {"Korean", "🇰🇷", ["#FFFFFF", "#CD2E3A", "#0047A0", "#000000"]},
    "la" => {"Latin", nil, nil},
    # Inherited from lt-lt
    "lt" => {"Lithuanian", "🇱🇹", ["#FDB913", "#006A44", "#C1272D"]},
    "lt-lt" => {"Lithuanian", "🇱🇹", ["#FDB913", "#006A44", "#C1272D"]},
    # Inherited from lv-lv
    "lv" => {"Latvian", "🇱🇻", ["#9E3039", "#FFFFFF"]},
    "lv-lv" => {"Latvian", "🇱🇻", ["#9E3039", "#FFFFFF"]},
    # Inherited from mk-mk
    "mk" => {"Macedonian", "🇲🇰", ["#D20000", "#FFE600"]},
    "mk-mk" => {"Macedonian", "🇲🇰", ["#D20000", "#FFE600"]},
    # Inherited from mn-mn
    "mn" => {"Mongolian", "🇲🇳", ["#C40000", "#0066B3", "#FFD500"]},
    "mn-mn" => {"Mongolian", "🇲🇳", ["#C40000", "#0066B3", "#FFD500"]},
    # Inherited from ms-my
    "ms" => {"Malay", "🇲🇾", ["#CC0000", "#FFFFFF", "#000066", "#FFCC00"]},
    "ms-my" => {"Malay", "🇲🇾", ["#CC0000", "#FFFFFF", "#000066", "#FFCC00"]},
    # Inherited from mt-mt
    "mt" => {"Maltese", "🇲🇹", ["#FFFFFF", "#CC292C"]},
    "mt-mt" => {"Maltese", "🇲🇹", ["#FFFFFF", "#CC292C"]},
    # Inherited from nb-no
    "nb" => {"Norwegian Bokmål", "🇳🇴", ["#BA0C2F", "#FFFFFF", "#00205B"]},
    "nb-no" => {"Norwegian Bokmål", "🇳🇴", ["#BA0C2F", "#FFFFFF", "#00205B"]},
    # Inherited from nl-nl
    "nl" => {"Dutch", "🇳🇱", ["#AE1C28", "#FFFFFF", "#21468B"]},
    "nl-be" => {"Dutch", "🇧🇪", ["#000000", "#FAE042", "#ED2939"]},
    "nl-nl" => {"Dutch", "🇳🇱", ["#AE1C28", "#FFFFFF", "#21468B"]},
    # Inherited from nn-no
    "nn" => {"Norwegian Nynorsk", "🇳🇴", ["#BA0C2F", "#FFFFFF", "#00205B"]},
    "nn-no" => {"Norwegian Nynorsk", "🇳🇴", ["#BA0C2F", "#FFFFFF", "#00205B"]},
    # Inherited from pl-pl
    "pl" => {"Polish", "🇵🇱", ["#FFFFFF", "#DC143C"]},
    "pl-pl" => {"Polish", "🇵🇱", ["#FFFFFF", "#DC143C"]},
    # Inherited from pt-pt
    "pt" => {"Portuguese", "🇵🇹", ["#046A38", "#DA291C", "#FFE900", "#002D73"]},
    "pt-br" => {"Portuguese", "🇧🇷", ["#009B3A", "#FFCC29", "#002776"]},
    "pt-pt" => {"Portuguese", "🇵🇹", ["#046A38", "#DA291C", "#FFE900", "#002D73"]},
    # Inherited from ro-ro
    "ro" => {"Romanian", "🇷🇴", ["#002B7F", "#FCD116", "#CE1126"]},
    "ro-ro" => {"Romanian", "🇷🇴", ["#002B7F", "#FCD116", "#CE1126"]},
    # Inherited from ru-ru
    "ru" => {"Russian", "🇷🇺", ["#FFFFFF", "#0039A6", "#D52B1E"]},
    "ru-ru" => {"Russian", "🇷🇺", ["#FFFFFF", "#0039A6", "#D52B1E"]},
    "ru-ua" => {"Russian", "🇺🇦", ["#005BBB", "#FFD500"]},
    # Inherited from sk-sk
    "sk" => {"Slovak", "🇸🇰", ["#FFFFFF", "#0B4EA2", "#EE1C25"]},
    "sk-sk" => {"Slovak", "🇸🇰", ["#FFFFFF", "#0B4EA2", "#EE1C25"]},
    # Inherited from sl-si
    "sl" => {"Slovenian", "🇸🇮", ["#FFFFFF", "#0000FF", "#FF0000"]},
    "sl-si" => {"Slovenian", "🇸🇮", ["#FFFFFF", "#0000FF", "#FF0000"]},
    # Inherited from sq-al
    "sq" => {"Albanian", "🇦🇱", ["#FF0000", "#000000"]},
    "sq-al" => {"Albanian", "🇦🇱", ["#FF0000", "#000000"]},
    # Inherited from sr-rs
    "sr" => {"Serbian", "🇷🇸", ["#C6363C", "#0C4076", "#FFFFFF"]},
    "sr-rs" => {"Serbian", "🇷🇸", ["#C6363C", "#0C4076", "#FFFFFF"]},
    # Inherited from sv-se
    "sv" => {"Swedish", "🇸🇪", ["#006AA7", "#FFCD00"]},
    "sv-fi" => {"Swedish", "🇫🇮", ["#FFFFFF", "#003580"]},
    "sv-se" => {"Swedish", "🇸🇪", ["#006AA7", "#FFCD00"]},
    # Inherited from sw-ke
    "sw" => {"Swahili", "🇰🇪", ["#000000", "#BB0000", "#008800", "#FFFFFF"]},
    "sw-ke" => {"Swahili", "🇰🇪", ["#000000", "#BB0000", "#008800", "#FFFFFF"]},
    # Inherited from ta-in
    "ta" => {"Tamil", "🇮🇳", ["#FF9933", "#FFFFFF", "#138808", "#000080"]},
    "ta-in" => {"Tamil", "🇮🇳", ["#FF9933", "#FFFFFF", "#138808", "#000080"]},
    # Inherited from th-th
    "th" => {"Thai", "🇹🇭", ["#A51931", "#FFFFFF", "#2E2A4D"]},
    "th-th" => {"Thai", "🇹🇭", ["#A51931", "#FFFFFF", "#2E2A4D"]},
    # Inherited from tr-tr
    "tr" => {"Turkish", "🇹🇷", ["#E30A17", "#FFFFFF"]},
    "tr-tr" => {"Turkish", "🇹🇷", ["#E30A17", "#FFFFFF"]},
    # Inherited from uk-ua
    "uk" => {"Ukrainian", "🇺🇦", ["#005BBB", "#FFD500"]},
    "uk-ua" => {"Ukrainian", "🇺🇦", ["#005BBB", "#FFD500"]},
    # Inherited from ur-pk
    "ur" => {"Urdu", "🇵🇰", ["#006633", "#FFFFFF"]},
    "ur-pk" => {"Urdu", "🇵🇰", ["#006633", "#FFFFFF"]},
    # Inherited from uz-uz
    "uz" => {"Uzbek", "🇺🇿", ["#0072CE", "#FFFFFF", "#009A44", "#CE1126"]},
    "uz-uz" => {"Uzbek", "🇺🇿", ["#0072CE", "#FFFFFF", "#009A44", "#CE1126"]},
    # Inherited from vi-vn
    "vi" => {"Vietnamese", "🇻🇳", ["#DA251D", "#FFFF00"]},
    "vi-vn" => {"Vietnamese", "🇻🇳", ["#DA251D", "#FFFF00"]},
    # No single default like zh-zh, stays nil
    "zh" => {"Chinese", nil, nil},
    "zh-cn" => {"Simplified Chinese", "🇨🇳", ["#EE1C25", "#FFFF00"]},
    "zh-hk" => {"Traditional Chinese", "🇭🇰", ["#DE2910", "#FFFFFF"]},
    "zh-sg" => {"Simplified Chinese", "🇸🇬", ["#ED2939", "#FFFFFF"]},
    "zh-tw" => {"Traditional Chinese", "🇹🇼", ["#FE0000", "#000095", "#FFFFFF"]}
  }

  # Now define the pre-compiled map using the struct definition above
  # Use struct! for compile-time safety - it raises if the struct is invalid
  @locale_map Map.new(@raw_locale_data, fn {locale, {language_name, unicode_flag, flag_colors}} ->
                {
                  locale,
                  %Kanta.LocaleInfo{
                    language_name: language_name,
                    unicode_flag: unicode_flag,
                    flag_colors: flag_colors
                  }
                }
              end)
  @all_locales Enum.map(@raw_locale_data, fn {_locale, {language_name, unicode_flag, flag_colors}} ->
                 %Kanta.LocaleInfo{
                   language_name: language_name,
                   unicode_flag: unicode_flag,
                   flag_colors: flag_colors
                 }
               end)

  # --- Public API ---
  @doc """
  Retrieves metadata for a given locale string.

  Accepts a locale string (e.g., "en-US", "pt-BR", "fr"). Case is ignored.
  Returns a `%LocaleInfo{}` struct on success, or `nil` if the locale
  is not found or the input is invalid.

  ## Examples

      iex> Kanta.LocaleInfo.get_locale_metadata("pt-BR")
      %Kanta.LocaleInfo{
        language_name: "Portuguese",
        unicode_flag: "🇧🇷",
        flag_colors: ["#009B3A", "#FFCC29", "#002776"]
      }

      iex> Kanta.LocaleInfo.get_locale_metadata("pl") # Polish base code
      %Kanta.LocaleInfo{
        language_name: "Polish",
        unicode_flag: "🇵🇱", # Inherited flag
        flag_colors: ["#FFFFFF", "#DC143C"] # Inherited colors
      }

      iex> Kanta.LocaleInfo.get_locale_metadata("pl-pl") # Polish regional code
      %Kanta.LocaleInfo{
        language_name: "Polish",
        unicode_flag: "🇵🇱",
        flag_colors: ["#FFFFFF", "#DC143C"]
      }

      iex> Kanta.LocaleInfo.get_locale_metadata("en") # English base code (no fallback)
      %Kanta.LocaleInfo{language_name: "English", unicode_flag: nil, flag_colors: nil}

      iex> Kanta.LocaleInfo.get_locale_metadata("xx-yy")
      nil

      iex> Kanta.LocaleInfo.get_locale_metadata(123)
      nil
  """

  def list_locale_info(), do: @all_locales

  def get_locale_info(locale_string) when is_binary(locale_string) do
    normalized_locale = String.downcase(locale_string)
    # Simple lookup in the pre-compiled static map
    Map.get(@locale_map, normalized_locale)
  end

  def get_locale_info(_) do
    # Handle non-binary input
    nil
  end
end
