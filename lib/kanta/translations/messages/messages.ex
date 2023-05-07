defmodule Kanta.Translations.Messages do
  import Ecto.Query, only: [from: 2]

  alias Kanta.Cache
  alias Kanta.Repo

  alias Kanta.Translations.Message

  @cache_prefix "message_"
  @ttl :timer.seconds(3600)

  def list_messages_by([{:domain_id, domain_id}]) do
    query =
      from m in Message,
        where: m.domain_id == ^domain_id

    Repo.get_repo().all(query)
    |> Repo.get_repo().preload([:singular_translations, :plural_translations])
  end

  def get_messages_count do
    Repo.get_repo().aggregate(Message, :count)
  end

  def get_message(id) do
    Repo.get_repo().get(Message, id)
  end

  def get_message_by(params) do
    cache_key = @cache_prefix <> URI.encode_query(params)

    case Cache.get(cache_key) do
      nil ->
        case Repo.get_repo().get_by(Message, params) do
          %Message{} = message ->
            Cache.put(cache_key, message, ttl: @ttl)

            message

          _ ->
            :not_found
        end

      cached_message ->
        cached_message
    end
  end
end
