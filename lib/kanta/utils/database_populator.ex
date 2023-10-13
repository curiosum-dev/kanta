defmodule Kanta.Utils.DatabasePopulator do
  @moduledoc false

  import Ecto.Changeset

  alias Kanta.Repo
  alias Kanta.Utils.GetSchemata

  @resource_name_to_schema GetSchemata.call()
                           |> Map.new()

  @spec call(atom(), String.t(), [map()]) :: no_return()
  def call(repo \\ Repo.get_repo(), resource_name, entries) do
    schema = @resource_name_to_schema[resource_name]

    entries
    |> Enum.each(&populate(repo, schema, &1))
  end

  defp populate(repo, %{schema: schema, conflict_target: conflict_target}, entry) do
    schema
    |> struct()
    |> change(entry |> keys_to_atoms())
    |> repo.insert!(on_conflict: :replace_all, conflict_target: conflict_target)
  end

  defp keys_to_atoms(map) do
    Map.new(map, &reduce_keys_to_atoms/1)
  end

  defp reduce_keys_to_atoms({"message_type", "singular"}) do
    {:message_type, :singular}
  end

  defp reduce_keys_to_atoms({"message_type", "plural"}) do
    {:message_type, :plural}
  end

  defp reduce_keys_to_atoms({key, val}) when is_map(val),
    do: {String.to_existing_atom(key), keys_to_atoms(val)}

  defp reduce_keys_to_atoms({key, val}), do: {String.to_existing_atom(key), val}
end
