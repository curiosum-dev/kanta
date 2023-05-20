defmodule Kanta.Plugins.POWriter do
  @moduledoc """
  Kanta .po files overwriting plugin
  """

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  def init(_opts) do
    {:ok, %{}}
  end

  def validate(_opts) do
    :ok
  end
end
