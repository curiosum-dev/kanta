defmodule Kanta.Translations.Messages do
  alias Kanta.Cache
  alias Kanta.Repo

  alias Kanta.Translations.Message
  alias Kanta.Translations.MessageQueries

  def list_messages_by(params) do
    MessageQueries.base()
    |> MessageQueries.filter_query(params["filter"])
    |> Repo.get_repo().all()
    |> Repo.get_repo().preload([:singular_translations, :plural_translations])
  end

  def get_messages_count do
    Repo.get_repo().aggregate(Message, :count)
  end

  def get_message(id) do
    Repo.get_repo().get(Message, id)
  end

  def get_message_by(params) do
    MessageQueries.base()
    |> MessageQueries.filter_query(params["filter"])
    |> Repo.get_repo().one()
  end
end
