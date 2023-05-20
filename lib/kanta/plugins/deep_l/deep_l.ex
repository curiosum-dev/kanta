defmodule Kanta.Plugins.DeepL do
  @moduledoc """
  Kanta DeepL integration plugin
  """

  use GenServer

  alias Kanta.Plugins.DeepL.Adapter

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  def init(_opts) do
    {:ok, %{}}
  end

  def validate(opts) do
    case Keyword.get(opts, :api_key) do
      api_key when is_binary(api_key) ->
        if String.ends_with?(api_key, "fx"), do: :ok, else: {:error, "invalid DeepL API key"}

      nil ->
        {:error, "missing DeepL API key"}
    end
  end

  def usage do
    Adapter.usage()
  end
end
