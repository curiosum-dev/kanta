defmodule Kanta.Cache do
  use GenServer
  alias Kanta.EtsCacheAdapter

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(_) do
    cache_adapter =
      case Application.get_env(:kanta, :cache_adapter) do
        nil -> EtsCacheAdapter
        :ets -> EtsCacheAdapter
        custom_adapter when is_atom(custom_adapter) -> custom_adapter
      end

    cache_adapter.init()

    {:ok, cache_adapter}
  end

  @impl true
  def handle_call({:get_cached_translation, locale, domain, msgctxt, msgid}, _from, cache_adapter) do
    {:reply, cache_adapter.get_cached_translation(locale, domain, msgctxt, msgid), cache_adapter}
  end

  def handle_call(
        {:cache_translation, locale, domain, msgctxt, msgid, translated},
        _from,
        cache_adapter
      ) do
    {:reply, cache_adapter.cache_translation(locale, domain, msgctxt, msgid, translated),
     cache_adapter}
  end

  def get_cached_translation(locale, domain, msgctxt, msgid) do
    GenServer.call(__MODULE__, {:get_cached_translation, locale, domain, msgctxt, msgid})
  end

  def cache_translation(locale, domain, msgctxt, msgid, translated) do
    GenServer.call(__MODULE__, {:cache_translation, locale, domain, msgctxt, msgid, translated})
  end
end
