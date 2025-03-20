defmodule Kanta.Test.Repo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :kanta,
    adapter: Ecto.Adapters.Postgres
end
