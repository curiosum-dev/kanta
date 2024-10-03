defmodule Kanta.Translations.PluralTranslations do
  @moduledoc """
  Plural translations Kanta subcontext
  """

  alias Kanta.Cache
  alias Kanta.Repo
  alias Kanta.Translations.PluralTranslation

  alias Kanta.Translations.PluralTranslations.Finders.{
    GetPluralTranslation,
    ListPluralTranslations
  }

  def list_plural_translations(params \\ []) do
    ListPluralTranslations.find(params)
  end

  def get_plural_translation(params \\ []) do
    GetPluralTranslation.find(params)
  end

  def create_plural_translation(attrs, opts \\ []) do
    attrs
    |> then(&PluralTranslation.changeset(%PluralTranslation{}, &1))
    |> Repo.get_repo().insert(opts)
    |> case do
      {:ok, plural_translation} ->
        cache_key =
          Cache.generate_cache_key("plural_translation",
            filter: [
              nplural_index: plural_translation.nplural_index,
              locale_id: plural_translation.locale_id,
              message_id: plural_translation.message_id
            ]
          )

        Cache.put(cache_key, plural_translation)
        {:ok, plural_translation}

      error ->
        error
    end
  end

  def update_plural_translation(translation, attrs, opts \\ []) do
    PluralTranslation.changeset(translation, attrs)
    |> Repo.get_repo().update(opts)
    |> case do
      {:ok, translation} ->
        cache_key =
          Cache.generate_cache_key("plural_translation",
            filter: [
              nplural_index: translation.nplural_index,
              locale_id: translation.locale_id,
              message_id: translation.message_id
            ]
          )

        Cache.put(cache_key, translation)

        {:ok, translation}

      error ->
        error
    end
  end
end
