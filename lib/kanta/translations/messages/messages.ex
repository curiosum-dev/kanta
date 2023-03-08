defmodule Kanta.Translations.Messages do
  use Nebulex.Caching

  alias Kanta.Cache
  alias Kanta.Repo

  alias Kanta.Translations.Message
  alias Kanta.Translations.MessageQueries

  @ttl :timer.hours(12)

  def list_messages_by(params) do
    MessageQueries.base()
    |> MessageQueries.filter_query(params["filter"])
    |> Repo.get_repo().all()
    |> Repo.get_repo().preload([:singular_translation, :plural_translations])
  end

  @decorate cacheable(cache: Cache, key: {Message, id}, opts: [ttl: @ttl])
  def get_message(id) do
    Repo.get_repo().get(Message, id)
  end

  @decorate cacheable(cache: Cache, key: {Message, params}, opts: [ttl: @ttl])
  def get_message_by(params) do
    MessageQueries.base()
    |> MessageQueries.filter_query(params["filter"])
    |> Repo.get_repo().one()
  end
end
