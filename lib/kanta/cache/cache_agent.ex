defmodule Kanta.Cache.Agent do
  use GenServer
  alias Kanta.Cache.Adapters.ETS
  alias Kanta.EmbeddedSchemas.SingularTranslation
  alias Kanta.Services.PopulateCacheWithStoredDataService

  def start_link(state) do
    {:ok, _pid} = GenServer.start_link(__MODULE__, state, name: __MODULE__)
    PopulateCacheWithStoredDataService.run()
  end

  def get_cached_translation_text(%SingularTranslation{} = translation) do
    GenServer.call(__MODULE__, {:get_cached_translation_text, translation})
  end

  def get_all_cached_translations do
    GenServer.call(__MODULE__, {:get_all_cached_translations})
  end

  def cache_translation(%SingularTranslation{} = translation) do
    GenServer.call(__MODULE__, {:cache_translation, translation})
  end

  def delete_cached_translation(%SingularTranslation{} = translation) do
    GenServer.call(__MODULE__, {:delete_cached_translation, translation})
  end

  @impl true
  def init(_) do
    {:ok, init_cache_adapter()}
  end

  @impl true
  def handle_call(
        {:get_cached_translation_text, %SingularTranslation{} = translation},
        _from,
        {cache_adapter, init_value}
      ) do
    {:reply, cache_adapter.get_cached_translation_text(translation, init_value),
     {cache_adapter, init_value}}
  end

  def handle_call(
        {:get_all_cached_translations},
        _from,
        {cache_adapter, init_value}
      ) do
    {:reply, cache_adapter.get_all_cached_translations(init_value), {cache_adapter, init_value}}
  end

  def handle_call(
        {:cache_translation, %SingularTranslation{} = translation},
        _from,
        {cache_adapter, init_value}
      ) do
    {:reply, cache_adapter.cache_translation(translation, init_value),
     {cache_adapter, init_value}}
  end

  def handle_call(
        {:delete_cached_translation, %SingularTranslation{} = translation},
        _from,
        {cache_adapter, init_value}
      ) do
    {:reply, cache_adapter.delete_cached_translation(translation, init_value),
     {cache_adapter, init_value}}
  end

  defp init_cache_adapter do
    cache_adapter =
      case Application.get_env(:kanta, :cache_adapter) do
        nil -> ETS
        :ets -> ETS
        custom_adapter when is_atom(custom_adapter) -> custom_adapter
      end

    {cache_adapter, cache_adapter.init()}
  end
end
