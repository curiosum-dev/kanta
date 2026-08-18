System.put_env("KANTA_SECRET_TOKEN", "kanta_test_secret_token")

Application.ensure_all_started(:kanta)

Kanta.Test.Repo.start_link()

{:ok, _} = Phoenix.PubSub.Supervisor.start_link(name: Kanta.Test.PubSub)
{:ok, _} = Kanta.Test.Endpoint.start_link()

Kanta.start_link(
  endpoint: Kanta.Test.Endpoint,
  repo: Kanta.Test.Repo,
  otp_name: :kanta,
  plugins: []
)

ExUnit.start()

# clear translations cache
Kanta.Cache.delete_all()

Ecto.Adapters.SQL.Sandbox.mode(Kanta.Test.Repo, :manual)
