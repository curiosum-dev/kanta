defmodule Kanta.Utils.Compilation do
  @moduledoc false

  @doc """
  Returns `true` if it is run during compilation.

  This function is used to handle translation messages during compilation time in macros and module attributes.
  """
  @spec compiling?() :: boolean()
  def compiling? do
    Code.ensure_loaded?(Code) &&
      Code.can_await_module_compilation?()
  end
end
