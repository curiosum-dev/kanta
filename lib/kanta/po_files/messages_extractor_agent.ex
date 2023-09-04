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
    MessagesExtractor.call()

    {:ok, %{}}
  end
end
