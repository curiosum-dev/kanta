defmodule Kanta.Translations.Messages do
  use Nebulex.Caching

  alias Kanta.Cache
  alias Kanta.Repo

  alias Kanta.Translations.Message
  alias Kanta.Translations.MessageQueries

  @ttl :timer.hours(12)

  @decorate cacheable(cache: Cache, key: {Message, domain_id}, opts: [ttl: @ttl])
  def list_messages_by_domain(domain_id) do
    MessageQueries.filter(domain_id: domain_id)
    |> Repo.get_repo().all()
    |> Repo.get_repo().preload([:singular_translation, :plural_translations])
  end
end
