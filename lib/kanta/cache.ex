defmodule Kanta.Cache do
  use Nebulex.Cache,
    otp_app: :kanta,
    adapter: Nebulex.Adapters.Partitioned,
    primary_storage_adapter: Nebulex.Adapters.Local
end
