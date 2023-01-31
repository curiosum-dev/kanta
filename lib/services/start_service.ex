defmodule Kanta.Services.StartService do
  @moduledoc false

  alias Kanta.POFiles.ExtractorAgent
  alias Kanta.Cache.Agent, as: CacheAgent

  use Supervisor

  @spec start_link(any) :: {:ok, pid}
  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      {ExtractorAgent, []},
      {CacheAgent, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
