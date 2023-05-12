defmodule Kanta.Translations.Locale.Finders.GetLocaleTranslationProgress do
  import Ecto.Query, only: [from: 2]

  alias Kanta.Translations.{PluralTranslation, SingularTranslation}

  def find(locale_id) do
    translations_count = translations_count(locale_id)

    case translations_count do
      0 ->
        0

      translations_count ->
        Float.ceil(translated_count(locale_id) / translations_count * 100)
    end
  end

  defp translations_count(locale_id) do
    singular_translations_query =
      from st in SingularTranslation,
        where: st.locale_id == ^locale_id,
        select: count()

    plural_translations_query =
      from pt in PluralTranslation,
        where: pt.locale_id == ^locale_id,
        select: count(),
        union: ^singular_translations_query

    Kanta.Repo.get_repo().all(plural_translations_query) |> Enum.sum()
  end

  defp translated_count(locale_id) do
    singular_translations_query =
      from st in SingularTranslation,
        where: st.locale_id == ^locale_id,
        where: not is_nil(st.translated_text),
        select: count()

    plural_translations_query =
      from pt in PluralTranslation,
        where: pt.locale_id == ^locale_id,
        where: not is_nil(pt.translated_text),
        select: count(),
        union: ^singular_translations_query

    Kanta.Repo.get_repo().all(plural_translations_query) |> Enum.sum()
  end
end
