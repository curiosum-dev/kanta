defmodule Kanta do
  @moduledoc """
  Main Kanta supervisor
  """

  use Supervisor

  alias Kanta.Registry
  alias Kanta.Config

  def start_link(opts) when is_list(opts) do
    conf = Config.new(opts)

    Supervisor.start_link(__MODULE__, conf, name: Registry.via(conf.name, nil, conf))
  end

  def child_spec(opts) do
    opts
    |> super()
    |> Supervisor.child_spec(id: Keyword.get(opts, :name, __MODULE__))
  end

  @impl Supervisor
  def init(conf) do
    %Config{plugins: plugins} = conf

    children = [
      {Kanta.MigrationVersionChecker, []}
    ]

    children = children ++ Enum.map(plugins, &plugin_child_spec(&1, conf))

    Supervisor.init(children, strategy: :one_for_one)
  end

  def config(name \\ __MODULE__), do: Registry.config(name)

  def plugin_enabled?(plugin_name) do
    case Enum.find(config().plugins, &(elem(&1, 0) == plugin_name)) do
      nil -> false
      _ -> true
    end
  end

  defp plugin_child_spec({module, opts}, conf) do
    name = Registry.via(conf.name, {:plugin, module})
    opts = Keyword.merge(opts, conf: conf, name: name)

    Supervisor.child_spec({module, opts}, id: {:plugin, module})
  end
end
