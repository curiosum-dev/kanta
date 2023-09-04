defmodule Kanta.Utils.ModuleUtils do
  @moduledoc false

  @doc """
  Checks if a module exists in the current application.
  """
  @spec module_exists?(atom()) :: boolean()
  def module_exists?(module_name) do
    module_name
    |> Code.ensure_compiled()
    |> (&match?({:module, _}, &1)).()
  end
end
