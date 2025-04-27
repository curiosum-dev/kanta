defmodule Kanta.Repo do
  def aggregate(queryable, aggregate, opts \\ []) do
    get_repo().aggregate(queryable, aggregate, opts)
  end

  def delete_all(queryable, opts \\ []) do
    get_repo().delete_all(queryable, opts)
  end

  def get(querable, id, opts \\ []) do
    get_repo().get(querable, id, opts)
  end

  def insert(struct_or_changeset, opts \\ []) do
    get_repo().insert(struct_or_changeset, opts)
  end

  def one(querable, opts \\ []) do
    get_repo().one(querable, opts)
  end

  def update(changeset, opts \\ []) do
    get_repo().update(changeset, opts)
  end

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
