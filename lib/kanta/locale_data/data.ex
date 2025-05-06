defmodule Kanta.LocaleInfo.Data do
  @moduledoc """
  Provides metadata for known locales based on IETF BCP 47 standards.
  Uses a pre-compiled static map for fast lookups. Base language codes
  (e.g., "pl") will inherit the flag/colors from their default regional
  variant (e.g., "pl-pl") if available and no specific region is defined
  for the base code.
  """

  alias Kanta.LocaleInfo

  # Raw data map
  @raw_locale_data %{
    # No af-af defined, stays nil
    "af" => {"af", "Afrikaans", nil, nil, "Afrikaans"},
    "af-za" =>
      {"af-za", "Afrikaans (South Africa)", "🇿🇦",
       ["#E03C31", "#FFFFFF", "#007749", "#000000", "#FFB81C", "#001489"], "Afrikaans"},
    # No ar-ar defined, stays nil
    "ar" => {"ar", "Arabic", nil, nil, "العربية"},
    "ar-ae" =>
      {"ar-ae", "Arabic (United Arab Emirates)", "🇦🇪",
       ["#FF0000", "#00732F", "#FFFFFF", "#000000"], "العربية"},
    "ar-sa" => {"ar-sa", "Arabic (Saudi Arabia)", "🇸🇦", ["#006C35", "#FFFFFF"], "العربية"},
    # Inherited from az-az
    "az" =>
      {"az", "Azerbaijani", "🇦🇿", ["#0092BC", "#E40000", "#3F9C35", "#FFFFFF"], "Azərbaycan dili"},
    "az-az" =>
      {"az-az", "Azerbaijani (Azerbaijan)", "🇦🇿", ["#0092BC", "#E40000", "#3F9C35", "#FFFFFF"],
       "Azərbaycan dili"},
    # Inherited from be-by
    "be" => {"be", "Belarusian", "🇧🇾", ["#CC0000", "#007A00", "#FFFFFF"], "Беларуская"},
    "be-by" =>
      {"be-by", "Belarusian (Belarus)", "🇧🇾", ["#CC0000", "#007A00", "#FFFFFF"], "Беларуская"},
    # Inherited from bg-bg
    "bg" => {"bg", "Bulgarian", "🇧🇬", ["#FFFFFF", "#00966E", "#D62612"], "Български"},
    "bg-bg" =>
      {"bg-bg", "Bulgarian (Bulgaria)", "🇧🇬", ["#FFFFFF", "#00966E", "#D62612"], "Български"},
    # Inherited from bn-bd
    "bn" => {"bn", "Bengali", "🇧🇩", ["#006A4E", "#F42A41"], "বাংলা"},
    "bn-bd" => {"bn-bd", "Bengali (Bangladesh)", "🇧🇩", ["#006A4E", "#F42A41"], "বাংলা"},
    # Inherited from bs-ba
    "bs" => {"bs", "Bosnian", "🇧🇦", ["#002395", "#FFCD00", "#FFFFFF"], "Bosanski"},
    "bs-ba" =>
      {"bs-ba", "Bosnian (Bosnia and Herzegovina)", "🇧🇦", ["#002395", "#FFCD00", "#FFFFFF"],
       "Bosanski"},
    # Inherited from ca-es
    "ca" => {"ca", "Catalan", "🇪🇸", ["#AA151B", "#F1BF00"], "Català"},
    "ca-es" => {"ca-es", "Catalan (Spain)", "🇪🇸", ["#AA151B", "#F1BF00"], "Català"},
    # Inherited from cs-cz
    "cs" => {"cs", "Czech", "🇨🇿", ["#FFFFFF", "#D7141A", "#11457E"], "Čeština"},
    "cs-cz" =>
      {"cs-cz", "Czech (Czech Republic)", "🇨🇿", ["#FFFFFF", "#D7141A", "#11457E"], "Čeština"},
    # Inherited from cy-gb
    "cy" => {"cy", "Welsh", "🇬🇧", ["#012169", "#FFFFFF", "#C8102E"], "Cymraeg"},
    "cy-gb" =>
      {"cy-gb", "Welsh (United Kingdom)", "🇬🇧", ["#012169", "#FFFFFF", "#C8102E"], "Cymraeg"},
    # Inherited from da-dk
    "da" => {"da", "Danish", "🇩🇰", ["#C60C30", "#FFFFFF"], "Dansk"},
    "da-dk" => {"da-dk", "Danish (Denmark)", "🇩🇰", ["#C60C30", "#FFFFFF"], "Dansk"},
    # Inherited from de-de
    "de" => {"de", "German", "🇩🇪", ["#000000", "#FF0000", "#FFCC00"], "Deutsch"},
    "de-at" => {"de-at", "German (Austria)", "🇦🇹", ["#ED2939", "#FFFFFF"], "Deutsch"},
    "de-ch" => {"de-ch", "German (Switzerland)", "🇨🇭", ["#FF0000", "#FFFFFF"], "Deutsch"},
    "de-de" => {"de-de", "German (Germany)", "🇩🇪", ["#000000", "#FF0000", "#FFCC00"], "Deutsch"},
    # Inherited from el-gr
    "el" => {"el", "Greek", "🇬🇷", ["#0D5EAF", "#FFFFFF"], "Ελληνικά"},
    "el-gr" => {"el-gr", "Greek (Greece)", "🇬🇷", ["#0D5EAF", "#FFFFFF"], "Ελληνικά"},
    # No single default like en-en, stays nil
    "en" => {"en", "English", nil, nil, "English"},
    "en-au" =>
      {"en-au", "English (Australia)", "🇦🇺", ["#00008B", "#FFFFFF", "#FF0000"], "English"},
    "en-ca" => {"en-ca", "English (Canada)", "🇨🇦", ["#FF0000", "#FFFFFF"], "English"},
    "en-gb" =>
      {"en-gb", "English (United Kingdom)", "🇬🇧", ["#012169", "#FFFFFF", "#C8102E"], "English"},
    "en-ie" => {"en-ie", "English (Ireland)", "🇮🇪", ["#009A49", "#FFFFFF", "#FF7900"], "English"},
    "en-in" =>
      {"en-in", "English (India)", "🇮🇳", ["#FF9933", "#FFFFFF", "#138808", "#000080"], "English"},
    "en-nz" =>
      {"en-nz", "English (New Zealand)", "🇳🇿", ["#00247D", "#FFFFFF", "#CC142E"], "English"},
    "en-us" =>
      {"en-us", "English (United States)", "🇺🇸", ["#B22234", "#FFFFFF", "#3C3B6E"], "English"},
    "en-za" =>
      {"en-za", "English (South Africa)", "🇿🇦",
       ["#E03C31", "#FFFFFF", "#007749", "#000000", "#FFB81C", "#001489"], "English"},
    "eo" => {"eo", "Esperanto", nil, nil, "Esperanto"},
    # Inherited from es-es
    "es" => {"es", "Spanish", "🇪🇸", ["#AA151B", "#F1BF00"], "Español"},
    "es-ar" =>
      {"es-ar", "Spanish (Argentina)", "🇦🇷", ["#74ACDF", "#FFFFFF", "#F6B40E"], "Español"},
    "es-cl" => {"es-cl", "Spanish (Chile)", "🇨🇱", ["#FFFFFF", "#0039A6", "#D52B1E"], "Español"},
    "es-co" => {"es-co", "Spanish (Colombia)", "🇨🇴", ["#FCD116", "#003893", "#CE1126"], "Español"},
    "es-es" => {"es-es", "Spanish (Spain)", "🇪🇸", ["#AA151B", "#F1BF00"], "Español"},
    "es-mx" => {"es-mx", "Spanish (Mexico)", "🇲🇽", ["#006847", "#FFFFFF", "#CE1126"], "Español"},
    "es-us" =>
      {"es-us", "Spanish (United States)", "🇺🇸", ["#B22234", "#FFFFFF", "#3C3B6E"], "Español"},
    # Special case, no change
    "es-419" => {"es-419", "Spanish (Latin America and Caribbean)", nil, nil, "Español"},
    # Inherited from et-ee
    "et" => {"et", "Estonian", "🇪🇪", ["#0072CE", "#000000", "#FFFFFF"], "Eesti"},
    "et-ee" => {"et-ee", "Estonian (Estonia)", "🇪🇪", ["#0072CE", "#000000", "#FFFFFF"], "Eesti"},
    # Inherited from eu-es
    "eu" => {"eu", "Basque", "🇪🇸", ["#AA151B", "#F1BF00"], "Euskara"},
    "eu-es" => {"eu-es", "Basque (Spain)", "🇪🇸", ["#AA151B", "#F1BF00"], "Euskara"},
    # Inherited from fa-ir
    "fa" => {"fa", "Persian", "🇮🇷", ["#239F40", "#FFFFFF", "#DA0000"], "فارسی"},
    "fa-ir" => {"fa-ir", "Persian (Iran)", "🇮🇷", ["#239F40", "#FFFFFF", "#DA0000"], "فارسی"},
    # Inherited from fi-fi
    "fi" => {"fi", "Finnish", "🇫🇮", ["#FFFFFF", "#003580"], "Suomi"},
    "fi-fi" => {"fi-fi", "Finnish (Finland)", "🇫🇮", ["#FFFFFF", "#003580"], "Suomi"},
    # Inherited from fo-fo
    "fo" => {"fo", "Faroese", "🇫🇴", ["#FFFFFF", "#003897", "#ED2939"], "Føroyskt"},
    "fo-fo" =>
      {"fo-fo", "Faroese (Faroe Islands)", "🇫🇴", ["#FFFFFF", "#003897", "#ED2939"], "Føroyskt"},
    # Inherited from fr-fr
    "fr" => {"fr", "French", "🇫🇷", ["#002395", "#FFFFFF", "#ED2939"], "Français"},
    "fr-be" => {"fr-be", "French (Belgium)", "🇧🇪", ["#000000", "#FAE042", "#ED2939"], "Français"},
    "fr-ca" => {"fr-ca", "French (Canada)", "🇨🇦", ["#FF0000", "#FFFFFF"], "Français"},
    "fr-ch" => {"fr-ch", "French (Switzerland)", "🇨🇭", ["#FF0000", "#FFFFFF"], "Français"},
    "fr-fr" => {"fr-fr", "French (France)", "🇫🇷", ["#002395", "#FFFFFF", "#ED2939"], "Français"},
    # Inherited from ga-ie
    "ga" => {"ga", "Irish", "🇮🇪", ["#009A49", "#FFFFFF", "#FF7900"], "Gaeilge"},
    "ga-ie" => {"ga-ie", "Irish (Ireland)", "🇮🇪", ["#009A49", "#FFFFFF", "#FF7900"], "Gaeilge"},
    # Inherited from gl-es
    "gl" => {"gl", "Galician", "🇪🇸", ["#AA151B", "#F1BF00"], "Galego"},
    "gl-es" => {"gl-es", "Galician (Spain)", "🇪🇸", ["#AA151B", "#F1BF00"], "Galego"},
    # Inherited from he-il
    "he" => {"he", "Hebrew", "🇮🇱", ["#FFFFFF", "#0038B8"], "עברית"},
    "he-il" => {"he-il", "Hebrew (Israel)", "🇮🇱", ["#FFFFFF", "#0038B8"], "עברית"},
    # Inherited from hi-in
    "hi" => {"hi", "Hindi", "🇮🇳", ["#FF9933", "#FFFFFF", "#138808", "#000080"], "हिन्दी"},
    "hi-in" =>
      {"hi-in", "Hindi (India)", "🇮🇳", ["#FF9933", "#FFFFFF", "#138808", "#000080"], "हिन्दी"},
    # Inherited from hr-hr
    "hr" => {"hr", "Croatian", "🇭🇷", ["#FF0000", "#FFFFFF", "#0000FF"], "Hrvatski"},
    "hr-hr" =>
      {"hr-hr", "Croatian (Croatia)", "🇭🇷", ["#FF0000", "#FFFFFF", "#0000FF"], "Hrvatski"},
    # Inherited from hu-hu
    "hu" => {"hu", "Hungarian", "🇭🇺", ["#CE2939", "#FFFFFF", "#477050"], "Magyar"},
    "hu-hu" => {"hu-hu", "Hungarian (Hungary)", "🇭🇺", ["#CE2939", "#FFFFFF", "#477050"], "Magyar"},
    # Inherited from hy-am
    "hy" => {"hy", "Armenian", "🇦🇲", ["#D90012", "#0033A0", "#F2A800"], "Հայերեն"},
    "hy-am" => {"hy-am", "Armenian (Armenia)", "🇦🇲", ["#D90012", "#0033A0", "#F2A800"], "Հայերեն"},
    # Inherited from id-id
    "id" => {"id", "Indonesian", "🇮🇩", ["#FF0000", "#FFFFFF"], "Bahasa Indonesia"},
    "id-id" =>
      {"id-id", "Indonesian (Indonesia)", "🇮🇩", ["#FF0000", "#FFFFFF"], "Bahasa Indonesia"},
    # Inherited from is-is
    "is" => {"is", "Icelandic", "🇮🇸", ["#02529C", "#FFFFFF", "#DC1E35"], "Íslenska"},
    "is-is" =>
      {"is-is", "Icelandic (Iceland)", "🇮🇸", ["#02529C", "#FFFFFF", "#DC1E35"], "Íslenska"},
    # Inherited from it-it
    "it" => {"it", "Italian", "🇮🇹", ["#009246", "#FFFFFF", "#CE2B37"], "Italiano"},
    "it-ch" => {"it-ch", "Italian (Switzerland)", "🇨🇭", ["#FF0000", "#FFFFFF"], "Italiano"},
    "it-it" => {"it-it", "Italian (Italy)", "🇮🇹", ["#009246", "#FFFFFF", "#CE2B37"], "Italiano"},
    # Inherited from ja-jp
    "ja" => {"ja", "Japanese", "🇯🇵", ["#FFFFFF", "#BC002D"], "日本語"},
    "ja-jp" => {"ja-jp", "Japanese (Japan)", "🇯🇵", ["#FFFFFF", "#BC002D"], "日本語"},
    # Inherited from ka-ge
    "ka" => {"ka", "Georgian", "🇬🇪", ["#FFFFFF", "#FF0000"], "ქართული"},
    "ka-ge" => {"ka-ge", "Georgian (Georgia)", "🇬🇪", ["#FFFFFF", "#FF0000"], "ქართული"},
    # Inherited from kk-kz
    "kk" => {"kk", "Kazakh", "🇰🇿", ["#00AFCA", "#FDE700"], "Қазақ тілі"},
    "kk-kz" => {"kk-kz", "Kazakh (Kazakhstan)", "🇰🇿", ["#00AFCA", "#FDE700"], "Қазақ тілі"},
    # Inherited from ko-kr
    "ko" => {"ko", "Korean", "🇰🇷", ["#FFFFFF", "#CD2E3A", "#0047A0", "#000000"], "한국어"},
    "ko-kr" =>
      {"ko-kr", "Korean (South Korea)", "🇰🇷", ["#FFFFFF", "#CD2E3A", "#0047A0", "#000000"], "한국어"},
    "la" => {"la", "Latin", nil, nil, "Latina"},
    # Inherited from lt-lt
    "lt" => {"lt", "Lithuanian", "🇱🇹", ["#FDB913", "#006A44", "#C1272D"], "Lietuvių"},
    "lt-lt" =>
      {"lt-lt", "Lithuanian (Lithuania)", "🇱🇹", ["#FDB913", "#006A44", "#C1272D"], "Lietuvių"},
    # Inherited from lv-lv
    "lv" => {"lv", "Latvian", "🇱🇻", ["#9E3039", "#FFFFFF"], "Latviešu"},
    "lv-lv" => {"lv-lv", "Latvian (Latvia)", "🇱🇻", ["#9E3039", "#FFFFFF"], "Latviešu"},
    # Inherited from mk-mk
    "mk" => {"mk", "Macedonian", "🇲🇰", ["#D20000", "#FFE600"], "Македонски"},
    "mk-mk" =>
      {"mk-mk", "Macedonian (North Macedonia)", "🇲🇰", ["#D20000", "#FFE600"], "Македонски"},
    # Inherited from mn-mn
    "mn" => {"mn", "Mongolian", "🇲🇳", ["#C40000", "#0066B3", "#FFD500"], "Монгол"},
    "mn-mn" =>
      {"mn-mn", "Mongolian (Mongolia)", "🇲🇳", ["#C40000", "#0066B3", "#FFD500"], "Монгол"},
    # Inherited from ms-my
    "ms" => {"ms", "Malay", "🇲🇾", ["#CC0000", "#FFFFFF", "#000066", "#FFCC00"], "Bahasa Melayu"},
    "ms-my" =>
      {"ms-my", "Malay (Malaysia)", "🇲🇾", ["#CC0000", "#FFFFFF", "#000066", "#FFCC00"],
       "Bahasa Melayu"},
    # Inherited from mt-mt
    "mt" => {"mt", "Maltese", "🇲🇹", ["#FFFFFF", "#CC292C"], "Malti"},
    "mt-mt" => {"mt-mt", "Maltese (Malta)", "🇲🇹", ["#FFFFFF", "#CC292C"], "Malti"},
    # Inherited from nb-no
    "nb" => {"nb", "Norwegian Bokmål", "🇳🇴", ["#BA0C2F", "#FFFFFF", "#00205B"], "Norsk bokmål"},
    "nb-no" =>
      {"nb-no", "Norwegian Bokmål (Norway)", "🇳🇴", ["#BA0C2F", "#FFFFFF", "#00205B"],
       "Norsk bokmål"},
    # Inherited from nl-nl
    "nl" => {"nl", "Dutch", "🇳🇱", ["#AE1C28", "#FFFFFF", "#21468B"], "Nederlands"},
    "nl-be" => {"nl-be", "Dutch (Belgium)", "🇧🇪", ["#000000", "#FAE042", "#ED2939"], "Nederlands"},
    "nl-nl" =>
      {"nl-nl", "Dutch (Netherlands)", "🇳🇱", ["#AE1C28", "#FFFFFF", "#21468B"], "Nederlands"},
    # Inherited from nn-no
    "nn" => {"nn", "Norwegian Nynorsk", "🇳🇴", ["#BA0C2F", "#FFFFFF", "#00205B"], "Norsk nynorsk"},
    "nn-no" =>
      {"nn-no", "Norwegian Nynorsk (Norway)", "🇳🇴", ["#BA0C2F", "#FFFFFF", "#00205B"],
       "Norsk nynorsk"},
    # Inherited from pl-pl
    "pl" => {"pl", "Polish", "🇵🇱", ["#FFFFFF", "#DC143C"], "Polski"},
    "pl-pl" => {"pl-pl", "Polish (Poland)", "🇵🇱", ["#FFFFFF", "#DC143C"], "Polski"},
    # Inherited from pt-pt
    "pt" => {"pt", "Portuguese", "", ["#046A38", "#DA291C", "#FFE900", "#002D73"], "Português"},
    "pt-br" =>
      {"pt-br", "Portuguese (Brazil)", "🇧🇷", ["#009B3A", "#FFCC29", "#002776"], "Português"},
    "pt-pt" =>
      {"pt-pt", "Portuguese (Portugal)", "🇵🇹", ["#046A38", "#DA291C", "#FFE900", "#002D73"],
       "Português"},
    # Inherited from ro-ro
    "ro" => {"ro", "Romanian", "🇷🇴", ["#002B7F", "#FCD116", "#CE1126"], "Română"},
    "ro-ro" => {"ro-ro", "Romanian (Romania)", "🇷🇴", ["#002B7F", "#FCD116", "#CE1126"], "Română"},
    # Inherited from ru-ru
    "ru" => {"ru", "Russian", "🇷🇺", ["#FFFFFF", "#0039A6", "#D52B1E"], "Русский"},
    "ru-ru" => {"ru-ru", "Russian (Russia)", "🇷🇺", ["#FFFFFF", "#0039A6", "#D52B1E"], "Русский"},
    "ru-ua" => {"ru-ua", "Russian (Ukraine)", "🇺🇦", ["#005BBB", "#FFD500"], "Русский"},
    # Inherited from sk-sk
    "sk" => {"sk", "Slovak", "🇸🇰", ["#FFFFFF", "#0B4EA2", "#EE1C25"], "Slovenčina"},
    "sk-sk" =>
      {"sk-sk", "Slovak (Slovakia)", "🇸🇰", ["#FFFFFF", "#0B4EA2", "#EE1C25"], "Slovenčina"},
    # Inherited from sl-si
    "sl" => {"sl", "Slovenian", "🇸🇮", ["#FFFFFF", "#0000FF", "#FF0000"], "Slovenščina"},
    "sl-si" =>
      {"sl-si", "Slovenian (Slovenia)", "🇸🇮", ["#FFFFFF", "#0000FF", "#FF0000"], "Slovenščina"},
    # Inherited from sq-al
    "sq" => {"sq", "Albanian", "🇦🇱", ["#FF0000", "#000000"], "Shqip"},
    "sq-al" => {"sq-al", "Albanian (Albania)", "🇦🇱", ["#FF0000", "#000000"], "Shqip"},
    # Inherited from sr-rs
    "sr" => {"sr", "Serbian", "🇷🇸", ["#C6363C", "#0C4076", "#FFFFFF"], "Српски"},
    "sr-rs" => {"sr-rs", "Serbian (Serbia)", "🇷🇸", ["#C6363C", "#0C4076", "#FFFFFF"], "Српски"},
    # Inherited from sv-se
    "sv" => {"sv", "Swedish", "🇸🇪", ["#006AA7", "#FFCD00"], "Svenska"},
    "sv-fi" => {"sv-fi", "Swedish (Finland)", "🇫🇮", ["#FFFFFF", "#003580"], "Svenska"},
    "sv-se" => {"sv-se", "Swedish (Sweden)", "🇸🇪", ["#006AA7", "#FFCD00"], "Svenska"},
    # Inherited from sw-ke
    "sw" => {"sw", "Swahili", "🇰🇪", ["#000000", "#BB0000", "#008800", "#FFFFFF"], "Kiswahili"},
    "sw-ke" =>
      {"sw-ke", "Swahili (Kenya)", "🇰🇪", ["#000000", "#BB0000", "#008800", "#FFFFFF"], "Kiswahili"},
    # Inherited from ta-in
    "ta" => {"ta", "Tamil", "🇮🇳", ["#FF9933", "#FFFFFF", "#138808", "#000080"], "தமிழ்"},
    "ta-in" =>
      {"ta-in", "Tamil (India)", "🇮🇳", ["#FF9933", "#FFFFFF", "#138808", "#000080"], "தமிழ்"},
    # Inherited from th-th
    "th" => {"th", "Thai", "🇹🇭", ["#A51931", "#FFFFFF", "#2E2A4D"], "ไทย"},
    "th-th" => {"th-th", "Thai (Thailand)", "🇹🇭", ["#A51931", "#FFFFFF", "#2E2A4D"], "ไทย"},
    # Inherited from tr-tr
    "tr" => {"tr", "Turkish", "🇹🇷", ["#E30A17", "#FFFFFF"], "Türkçe"},
    "tr-tr" => {"tr-tr", "Turkish (Turkey)", "🇹🇷", ["#E30A17", "#FFFFFF"], "Türkçe"},
    # Inherited from uk-ua
    "uk" => {"uk", "Ukrainian", "🇺🇦", ["#005BBB", "#FFD500"], "Українська"},
    "uk-ua" => {"uk-ua", "Ukrainian (Ukraine)", "🇺🇦", ["#005BBB", "#FFD500"], "Українська"},
    # Inherited from ur-pk
    "ur" => {"ur", "Urdu", "🇵🇰", ["#006633", "#FFFFFF"], "اردو"},
    "ur-pk" => {"ur-pk", "Urdu (Pakistan)", "🇵🇰", ["#006633", "#FFFFFF"], "اردو"},
    # Inherited from uz-uz
    "uz" => {"uz", "Uzbek", "🇺🇿", ["#0072CE", "#FFFFFF", "#009A44", "#CE1126"], "O'zbek"},
    "uz-uz" =>
      {"uz-uz", "Uzbek (Uzbekistan)", "🇺🇿", ["#0072CE", "#FFFFFF", "#009A44", "#CE1126"], "O'zbek"},
    # Inherited from vi-vn
    "vi" => {"vi", "Vietnamese", "🇻🇳", ["#DA251D", "#FFFF00"], "Tiếng Việt"},
    "vi-vn" => {"vi-vn", "Vietnamese (Vietnam)", "🇻🇳", ["#DA251D", "#FFFF00"], "Tiếng Việt"},
    # No single default like zh-zh, stays nil
    "zh" => {"zh", "Chinese", nil, nil, "中文"},
    "zh-cn" => {"zh-cn", "Simplified Chinese (China)", "🇨🇳", ["#EE1C25", "#FFFF00"], "简体中文"},
    "zh-hk" => {"zh-hk", "Traditional Chinese (Hong Kong)", "🇭🇰", ["#DE2910", "#FFFFFF"], "繁體中文"},
    "zh-sg" => {"zh-sg", "Simplified Chinese (Singapore)", "🇸🇬", ["#ED2939", "#FFFFFF"], "简体中文"},
    "zh-tw" =>
      {"zh-tw", "Traditional Chinese (Taiwan)", "🇹🇼", ["#FE0000", "#000095", "#FFFFFF"], "繁體中文"}
  }

  @locale_map Map.new(@raw_locale_data, fn {locale,
                                            {locale_code, language_name, unicode_flag,
                                             flag_colors, native_name}} ->
                {
                  locale,
                  %LocaleInfo{
                    locale: locale_code,
                    language_name: language_name,
                    language_native_name: native_name,
                    unicode_flag: unicode_flag,
                    flag_colors: flag_colors
                  }
                }
              end)
  @all_locales Enum.map(@locale_map, fn {_key, locale_info} -> locale_info end)

  # --- Public API ---
  @doc """
  Retrieves metadata for a given locale string.

  Accepts a locale string (e.g., "en-US", "pt-BR", "fr"). Case is ignored.
  Returns a `%LocaleInfo{}` struct on success, or `nil` if the locale
  is not found or the input is invalid.

  ## Examples

      iex> Kanta.LocaleInfo.get_locale_metadata("pt-BR")
      %Kanta.LocaleInfo{
        locale: "pt-br",
        language_name: "Portuguese",
        unicode_flag: "🇧🇷",
        flag_colors: ["#009B3A", "#FFCC29", "#002776"]
      }

      iex> Kanta.LocaleInfo.get_locale_metadata("pl") # Polish base code
      %Kanta.LocaleInfo{
        locale: "pl",
        language_name: "Polish",
        unicode_flag: "🇵🇱", # Inherited flag
        flag_colors: ["#FFFFFF", "#DC143C"] # Inherited colors
      }

      iex> Kanta.LocaleInfo.get_locale_metadata("pl-pl") # Polish regional code
      %Kanta.LocaleInfo{
        locale: "pl-pl",
        language_name: "Polish",
        unicode_flag: "🇵🇱",
        flag_colors: ["#FFFFFF", "#DC143C"]
      }

      iex> Kanta.LocaleInfo.get_locale_metadata("en") # English base code (no fallback)
      %Kanta.LocaleInfo{locale: "en", language_name: "English", unicode_flag: nil, flag_colors: nil}

      iex> Kanta.LocaleInfo.get_locale_metadata("xx-yy")
      nil

      iex> Kanta.LocaleInfo.get_locale_metadata(123)
      nil
  """

  def list_locale_info(), do: @all_locales

  @doc """
  Retrieves locale information for a given locale string.

  Accepts a locale string (e.g., "en-US", "pt-BR", "fr"). Case is ignored.
  Returns a `%LocaleInfo{}` struct if the locale is found, or `nil` if the locale
  is not recognized or the input is invalid.

  ## Examples

      iex> Kanta.LocaleInfo.Data.get_locale_info("en-US")
      %Kanta.LocaleInfo{
        locale: "en-us",
        language_name: "English",
        unicode_flag: "🇺🇸",
        flag_colors: ["#B22234", "#FFFFFF", "#3C3B6E"]
      }

      iex> Kanta.LocaleInfo.Data.get_locale_info("fr")
      %Kanta.LocaleInfo{
        locale: "fr",
        language_name: "French",
        unicode_flag: "🇫🇷",
        flag_colors: ["#002395", "#FFFFFF", "#ED2939"]
      }

      iex> Kanta.LocaleInfo.Data.get_locale_info("invalid-locale")
      nil

      iex> Kanta.LocaleInfo.Data.get_locale_info(123)
      nil
  """
  def get_locale_info(locale_string) when is_binary(locale_string) do
    normalized_locale =
      locale_string
      |> String.downcase()
      |> String.replace("_", "-")

    # Simple lookup in the pre-compiled static map
    Map.get(@locale_map, normalized_locale, %LocaleInfo{locale: normalized_locale})
  end

  def get_locale_info(_) do
    # Handle non-binary input
    nil
  end
end
