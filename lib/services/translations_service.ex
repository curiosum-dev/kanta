defmodule Kanta.TranslationsService do
  alias Kanta.POFiles.ExtractorAgent
  alias Kanta.Translations

  defp get_missing_singular_translations do
    get_missing_copied_singular_translations() ++ get_missing_po_singular_translations()
  end

  defp get_missing_copied_singular_translations,
    do: Translations.list_singular_translations(text: nil)

  defp get_missing_po_singular_translations do
    # TODO: refactor
    ExtractorAgent.get_singular_translations()
    |> Enum.filter(&Translations.get_singular_translation/1)
  end

  defp get_translated_singular_translations do
    Kanta.Translations.list_singular_translations_with_text_not_null()
  end

  defp get_initial_state do
    missing_singular_translations = get_missing_singular_translations()
    translated_singular_translations = get_translated_singular_translations()

    %{
      missing_singular_translations: missing_singular_translations,
      missing_singular_translations_count: Enum.count(missing_singular_translations),
      translated_singular_translations: translated_singular_translations,
      translated_singular_translations_count: Enum.count(translated_singular_translations)
    }
  end
end
