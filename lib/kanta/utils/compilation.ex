defmodule Kanta.Utils.Compilation do
  @moduledoc false

  def compiling? do
    Code.ensure_loaded?(Code) &&
      apply(Code, :can_await_module_compilation?, [])
  end
end
