defmodule Kanta.Test.Migration do
  @moduledoc false

  use Ecto.Migration

  @current_version Kanta.Migrations.Postgresql.current_version()

  def up do
    Kanta.Migration.up(version: @current_version)
  end

  def down do
    Kanta.Migration.down(version: @current_version)
  end
end
