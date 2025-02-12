defmodule Kanta.Repo do
  def get_repo do
    Kanta.config().repo
  end

  def get_adapter_name do
    case get_repo().__adapter__() do
      Ecto.Adapters.Postgres -> :postgres
      Ecto.Adapters.SQLite3 -> :sqlite
    end
  end
end
