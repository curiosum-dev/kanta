defmodule Kanta.Test.Repo.Migrations.UpdateKantaMigrations do
  use Ecto.Migration

  def up do
     Kanta.Migration.up(version: 4)
   end

   def down do
     Kanta.Migration.down(version: 4)
   end
end
