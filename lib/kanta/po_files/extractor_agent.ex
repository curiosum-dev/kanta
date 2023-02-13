defmodule Kanta.POFiles.ExtractorAgent do
  use GenServer
  alias Kanta.POFiles.Extractor
  alias Kanta.Translations.SingularTranslation

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def get_singular_translations do
    GenServer.call(__MODULE__, {:get_singular_translations})
  end

  @impl true
  def init(_) do
    translations = Extractor.get_translations()

    singular_translations = Enum.filter(translations, &match?(%SingularTranslation{}, &1))
    plurar_translations = []

    {:ok,
     %{
       singular_translations: singular_translations,
       plurar_translations: plurar_translations
     }}
  end

  @impl true
  def handle_call({:get_singular_translations}, _from, state) do
    {:reply, state.translations, state}
  end
end
