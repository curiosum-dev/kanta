defmodule Kanta.POFiles.MessagesExtractorAgent do
  @moduledoc """
  GenServer responsible for extracting messages and translations from .po files
  """

  use GenServer
  alias Kanta.POFiles.MessagesExtractor

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(_) do
    if message_extractor_available?() do
      MessagesExtractor.call()
    end

    {:ok, %{}}
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
