defmodule Kanta.Registry do
  @moduledoc """
  Kanta Registry
  """

  def child_spec(_arg) do
    [keys: :unique, name: __MODULE__]
    |> Registry.child_spec()
    |> Supervisor.child_spec(id: __MODULE__)
  end

  @doc """
  Fetch the config for an Kanta supervisor instance.

  ## Example

  Get the default instance config:

      Kanta.Registry.config(Kanta)

  Get config for a custom named instance:

      Kanta.Registry.config(MyApp.Kanta)
  """
  @spec config(Kanta.name()) :: Kanta.Config.t()
  def config(kanta_name) do
    case lookup(kanta_name) do
      {_pid, config} ->
        config

      _ ->
        raise RuntimeError, """
        No Kanta instance named `#{inspect(kanta_name)}` is running and config isn't available.
        """
    end
  end

  @doc """
  Find the `{pid, value}` pair for a registered Kanta process.

  ## Example

  Get the default instance config:

      Kanta.Registry.lookup(Kanta)

  Get a supervised module's pid:

      Kanta.Registry.lookup(Kanta, Kanta.Notifier)
  """
  def lookup(kanta_name, role \\ nil) do
    __MODULE__
    |> Registry.lookup(key(kanta_name, role))
    |> List.first()
  end

  @doc """
  Returns the pid of a supervised Kanta process, or `nil` if the process can't be found.

  ## Example

  Get the Kanta supervisor's pid:

      Kanta.Registry.whereis(Kanta)

  Get the pid for a plugin:

      Kanta.Registry.whereis(Kanta, {:plugin, MyApp.Kanta.Plugin})
  """
  def whereis(kanta_name, role \\ nil) do
    kanta_name
    |> via(role)
    |> GenServer.whereis()
  end

  @doc """
  Build a via tuple suitable for calls to a supervised Kanta process.

  ## Example

  For an Kanta supervisor:

      Kanta.Registry.via(Kanta)

  For a plugin:

      Kanta.Registry.via(Kanta, {:plugin, Kanta.DeepL.Plugin})
  """
  def via(kanta_name, role \\ nil, value \\ nil)
  def via(kanta_name, role, nil), do: {:via, Registry, {__MODULE__, key(kanta_name, role)}}

  def via(kanta_name, role, value),
    do: {:via, Registry, {__MODULE__, key(kanta_name, role), value}}

  defp key(kanta_name, nil), do: kanta_name
  defp key(kanta_name, role), do: {kanta_name, role}
end
