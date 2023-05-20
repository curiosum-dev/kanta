defmodule Kanta.PoFiles.Services.ExtractPluralTranslation do
  @moduledoc """
  Service for extracting plural messages and translations from .po files
  """

  alias Kanta.Repo
  alias Kanta.Translations
  alias Kanta.PoFiles.Services.ExtractMessage

  alias Kanta.Translations.Locale.Services.CreateLocaleFromIsoCode

  def call(attrs) do
    Repo.get_repo().transaction(fn ->
      with attrs <- Map.put(attrs, :message_type, :plural),
           {:ok, message} <- ExtractMessage.call(attrs),
           {:ok, locale} <- get_or_create_locale(attrs[:locale_name]) do
        create_or_update_plural_translations(attrs, message, locale)
      end
    end)
  end

  defp get_or_create_locale(iso639_code) do
    case Translations.get_locale(filter: [iso639_code: iso639_code]) do
      {:ok, locale} -> {:ok, locale}
      {:error, :locale, :not_found} -> CreateLocaleFromIsoCode.call(iso639_code)
    end
  end

  defp create_or_update_plural_translations(attrs, message, locale) do
    Enum.map(attrs[:plurals_map], fn {index, [original_text]} ->
      case Translations.get_plural_translation(
             filter: [message_id: message.id, locale_id: locale.id, nplural_index: index]
           ) do
        {:ok, translation} ->
          attrs
          |> Map.put(:original_text, original_text)
          |> then(&Translations.update_plural_translation(translation, &1))

        {:error, :plural_translation, :not_found} ->
          attrs
          |> Map.put(:nplural_index, index)
          |> Map.put(:original_text, original_text)
          |> Map.put(:message_id, message.id)
          |> Map.put(:locale_id, locale.id)
          |> Translations.create_plural_translation()
      end
    end)
    |> Enum.all?(&(elem(&1, 0) == :ok))
    |> case do
      true -> {:ok, []}
      false -> {:error, nil}
    end
  end
end
