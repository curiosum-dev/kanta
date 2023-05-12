defmodule Kanta.PoFiles.Services.ExtractSingularTranslation do
  alias Kanta.Repo
  alias Kanta.Translations
  alias Kanta.PoFiles.Services.ExtractMessage

  alias Kanta.Translations.Locale.Services.CreateLocaleFromIsoCode

  def call(attrs) do
    Repo.get_repo().transaction(fn ->
      with attrs <- Map.put(attrs, :message_type, :singular),
           {:ok, message} <- ExtractMessage.call(attrs),
           {:ok, locale} <- get_or_create_locale(attrs[:locale_name]),
           {:ok, translation} <- create_or_update_singular_translation(attrs, message, locale) do
        translation
      end
    end)
  end

  defp get_or_create_locale(iso639_code) do
    case Translations.get_locale(filter: [iso639_code: iso639_code]) do
      {:ok, locale} -> {:ok, locale}
      {:error, :locale, :not_found} -> CreateLocaleFromIsoCode.call(iso639_code)
    end
  end

  defp create_or_update_singular_translation(attrs, message, locale) do
    case Translations.get_singular_translation(
           filter: [message_id: message.id, locale_id: locale.id]
         ) do
      {:ok, translation} ->
        Translations.update_singular_translation(translation, attrs)

      {:error, :singular_translation, :not_found} ->
        attrs
        |> Map.put(:message_id, message.id)
        |> Map.put(:locale_id, locale.id)
        |> Translations.create_singular_translation()
    end
  end
end
