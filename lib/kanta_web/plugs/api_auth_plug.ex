defmodule KantaWeb.APIAuthPlug do
  import Plug.Conn

  @kanta_secret_token "KANTA_SECRET_TOKEN"

  def init(_opts), do: %{}

  def call(conn, _opts) do
    if is_bearer_token_valid?(conn) do
      conn
    else
      conn
      |> send_resp(
        401,
        "Incorrect authorization Bearer token."
      )
      |> halt()
    end
  end

  defp is_bearer_token_valid?(conn) do
    with {:ok, token} <- extract_bearer_token(conn),
         true <- is_secret_token_matching?(token) do
      true
    else
      _ -> false
    end
  end

  defp is_secret_token_matching?(token) do
    secret_token_env =
      @kanta_secret_token
      |> System.get_env()

    if is_nil(secret_token_env) do
      false
    else
      sha256(secret_token_env) == token
    end
  end

  defp extract_bearer_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        {:ok, token}

      _ ->
        :error
    end
  end

  defp sha256(token) do
    :crypto.hash(:sha256, token)
    |> Base.encode64()
  end
end
