defmodule Kanta.Storage do
  alias Kanta.Cache
  alias Kanta.Translation

  def get_translation(locale, domain, msgctxt, msgid) do
    filter = build_filter(locale, domain, msgctxt, msgid)

    case get_ecto_repo().get_by(Translation, filter) do
      nil ->
        :not_found

      %Translation{translated: translated} ->
        Cache.cache_translation(locale, domain, msgctxt, msgid, translated)
        {:ok, translated}
    end
  end

  def set_translation(locale, domain, msgctxt, msgid, translated) do
    Cache.cache_translation(locale, domain, msgctxt, msgid, translated)

    %Translation{}
    |> Translation.changeset(%{locale: locale, domain: domain, msgctxt: msgctxt, msgid: msgid, translated: translated})
    |> get_ecto_repo().insert_or_update!()
  end

  defp get_ecto_repo do
    Application.fetch_env!(:kanta, :ecto_repo)
  end

  defp build_filter(locale, domain, msgctxt, msgid) do
    [locale: locale, domain: domain, msgctxt: msgctxt, msgid: msgid]
    |> Enum.reduce(
      [],
      fn {key, value}, opts ->
        case is_nil(value) do
          true -> opts
          false -> Keyword.put(opts, key, value)
        end
      end
    )
  end
end
