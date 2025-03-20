defmodule Kanta.Test.DataCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  using do
    quote do
      use ExUnit.Case, async: false

      import ExUnit.CaptureLog
      import Kanta.Test.DataCase
    end
  end

  setup tags do
    # Explicitly check out a connection from the sandbox
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Kanta.Test.Repo)

    # Use shared mode unless the test is async
    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Kanta.Test.Repo, {:shared, self()})
    end

    :ok
  end
end
