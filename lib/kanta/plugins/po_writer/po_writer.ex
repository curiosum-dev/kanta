defmodule Kanta.Plugins.POWriter do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  def init(_opts) do
    {:ok, %{}}
  end

  def validate(opts) do
    :ok
  end
end
