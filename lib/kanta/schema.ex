defmodule Kanta.Schema do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema

      @primary_key {:id, Application.compile_env(:kanta, :schema_id_type, :id),
                    autogenerate: true}
      @foreign_key_type Application.compile_env(:kanta, :schema_id_type, :id)
    end
  end
end
