defmodule Kanta.Translations.Locale.Finders.ListLocalesWithTranslatedMessage do
  @moduledoc """
  Finder for getting locales for which we have translated message
  """

  import Ecto.Query, only: [from: 2]

  alias Kanta.Repo

  alias Kanta.Translations.{Locale, Message, PluralTranslation, SingularTranslation}

  def find(%Message{id: message_id, message_type: :singular}) do
    query =
      from l in Locale,
        join: st in SingularTranslation,
        on: st.locale_id == l.id,
        where: st.message_id == ^message_id,
        where: not is_nil(st.translated_text) or not is_nil(st.original_text),
        distinct: l.id

    Repo.get_repo().all(query)
  end

  def find(%Message{id: message_id, message_type: :plural}) do
    query =
      from l in Locale,
        join: pt in PluralTranslation,
        on: pt.locale_id == l.id,
        where: pt.message_id == ^message_id,
        where: not is_nil(pt.translated_text) or not is_nil(pt.original_text),
        distinct: l.id

    Repo.get_repo().all(query)
  end
end
