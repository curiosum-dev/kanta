defmodule Kanta.External.DeepL.Adapter do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://api-free.deepl.com"

  plug Tesla.Middleware.Headers, [
    {"Authorization", "DeepL-Auth-Key #{Application.get_env(:kanta, :deep_l_api_key)}"}
  ]

  plug Tesla.Middleware.JSON

  def request_translation(source_lang, target_lang, text) do
    post("/v2/translate", %{
      source_lang: source_lang,
      target_lang: target_lang,
      text: [text]
    })
    |> case do
      {:ok, %Tesla.Env{body: %{"translations" => translations}}} -> {:ok, translations}
      {_, %Tesla.Env{body: body, status: status}} -> {:error, status, body}
      error -> {:error, error}
    end
  end

  def usage do
    get("/v2/usage")
    |> case do
      {:ok, %Tesla.Env{body: body}} -> {:ok, body}
      {_, %Tesla.Env{body: body, status: status}} -> {:error, status, body}
      error -> {:error, error}
    end
  end
end
