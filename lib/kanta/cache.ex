defmodule Kanta.Cache do
  use Nebulex.Cache,
    otp_app: :kanta,
    adapter: Nebulex.Adapters.Partitioned,
    primary_storage_adapter: Nebulex.Adapters.Local

  def generate_cache_key(prefix, params) do
    Enum.reduce(params, prefix, fn {key, value}, acc ->
      case value do
        val when is_binary(val) ->
          acc <> "_" <> to_string(key) <> "_" <> URI.encode_query(val)

        val when is_list(val) ->
          acc <> "_" <> to_string(key) <> "_" <> (Enum.into(val, %{}) |> URI.encode_query())

        _val ->
          acc
      end
    end)
  end
end
