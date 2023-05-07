defmodule Kanta.Translations.Contexts do
  alias Kanta.Cache
  alias Kanta.Repo

  alias Kanta.Translations.Context

  @cache_prefix "context_"
  @ttl :timer.seconds(3600)

  def list_contexts do
    Repo.get_repo().all(Context)
  end

  def get_context(id) do
    Repo.get_repo().get(Context, id)
  end

  def get_context_by(params) do
    cache_key = @cache_prefix <> URI.encode_query(params)

    case Cache.get(cache_key) do
      nil ->
        case Repo.get_repo().get_by(Context, params) do
          %Context{} = context ->
            Cache.put(cache_key, context, ttl: @ttl)

            context

          _ ->
            :not_found
        end

      cached_context ->
        cached_context
    end
  end

  def get_or_create_context_by(params) do
    case get_context_by(params) do
      %Context{} = context -> context
      :not_found -> create_context!(%{name: params[:name]})
    end
  end

  defp create_context!(attrs) do
    %Kanta.Translations.Context{}
    |> Kanta.Translations.Context.changeset(attrs)
    |> Kanta.Repo.get_repo().insert!()
  end
end
