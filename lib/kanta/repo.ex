defmodule Kanta.Repo do
  def get_repo do
    Application.fetch_env!(:kanta, :ecto_repo)
  end
end
