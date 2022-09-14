defmodule Kanta.EtsCacheAdapter do
  @name :kanta_ets_cache

  def init() do
    IO.puts(inspect(:ets.new(@name, [:set, :public, :named_table])))
    IO.puts(inspect(self()))
  end

  def get_cached_translation(locale, domain, msgctxt, msgid) do
    IO.puts(inspect(@name))
    IO.puts(inspect(self()))

    IO.puts("""
      get_cached_translation
      locale = #{inspect(locale)}
      domain = #{inspect(domain)}
      msgctxt = #{inspect(msgctxt)}
      msgid = #{inspect(msgid)}
    """)

    key = get_key(locale, domain, msgctxt, msgid)

    case :ets.lookup(@name, key) do
      [{^key, translated}] -> {:ok, translated}
      _ -> :not_found
    end
  end

  def cache_translation(locale, domain, msgctxt, msgid, translated) do
    key = get_key(locale, domain, msgctxt, msgid)

    true = :ets.insert(@name, {key, translated})
  end

  defp get_key(locale, _domain, _msgctxt, msgid) do
    {locale, msgid}
  end
end
