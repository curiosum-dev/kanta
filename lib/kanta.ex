defmodule Kanta do
  use GenServer
  alias Kanta.POFiles.Extractor

  @kanta_tables ~w(kanta_locales kanta_domains kanta_messages kanta_singular_translations kanta_plural_translations)

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(_) do
    repo = Kanta.Repo.get_repo()

    if Enum.all?(@kanta_tables, &Ecto.Adapters.SQL.table_exists?(repo, &1)) do
      Extractor.parse_translations()
    end

    {:ok, %{}}
  end
end
