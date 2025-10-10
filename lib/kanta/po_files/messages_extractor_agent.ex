defmodule Kanta.POFiles.MessagesExtractorAgent do
  @moduledoc """
  GenServer responsible for extracting messages and translations from .po files
  """

  use GenServer
  alias Kanta.POFiles.MessagesExtractor
  alias Kanta.POFiles.Services.IdentifyStaleTranslations

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(_) do
    state =
      if message_extractor_available?() do
        MessagesExtractor.call()

        # Detect stale translations system-wide
        {:ok, result} = IdentifyStaleTranslations.call()

        %{stale_message_ids: result.stale_message_ids}
      else
        %{stale_message_ids: MapSet.new()}
      end

    {:ok, state}
  end

  @doc """
  Gets system-wide stale message IDs.

  ## Returns

    * `MapSet.t()` - Set of stale message IDs, or empty MapSet

  ## Examples

      iex> MessagesExtractorAgent.get_stale_message_ids()
      #MapSet<[1, 2, 3]>

  """
  def get_stale_message_ids do
    GenServer.call(__MODULE__, :get_stale_ids)
  end

  @doc """
  Updates system-wide stale message IDs.

  ## Arguments

    * `stale_ids` - MapSet of stale message IDs

  ## Examples

      iex> MessagesExtractorAgent.update_stale_message_ids(MapSet.new([1, 2]))
      :ok

  """
  def update_stale_message_ids(stale_ids) when is_struct(stale_ids, MapSet) do
    GenServer.call(__MODULE__, {:update_stale_ids, stale_ids})
  end

  @impl true
  def handle_call(:get_stale_ids, _from, state) do
    stale_ids = Map.get(state, :stale_message_ids, MapSet.new())
    {:reply, stale_ids, state}
  end

  @impl true
  def handle_call({:update_stale_ids, stale_ids}, _from, state) do
    new_state = Map.put(state, :stale_message_ids, stale_ids)
    {:reply, :ok, new_state}
  end

  defp message_extractor_available? do
    # Message extractor requires columns added in version 3 of Postgres migration and version 2 of SQLite migration.
    migrator =
      case Kanta.Repo.get_adapter_name() do
        :postgres -> Kanta.Migrations.Postgresql
        :sqlite -> Kanta.Migrations.SQLite3
      end

    migrated_version = migrator.migrated_version(%{repo: Kanta.Repo.get_repo()})

    case Kanta.Repo.get_adapter_name() do
      :postgres -> migrated_version >= 3
      :sqlite -> migrated_version >= 2
    end
  end
end
