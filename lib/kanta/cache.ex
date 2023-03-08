defmodule Kanta.Cache do
  use Nebulex.Cache,
    otp_app: :kanta,
    adapter: Nebulex.Adapters.Partitioned,
    primary_storage_adapter: Nebulex.Adapters.Local

  def match_update({:ok, value}), do: {true, value}
  def match_update({:error, _}), do: false
end
