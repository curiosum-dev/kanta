defmodule Kanta.Cache.Adapters.ETS do
  alias Kanta.EmbeddedSchemas.SingularTranslation

  def init() do
    :ets.new(:kanta_ets_cache, [:set, :public, :named_table])
  end

  def get_cached_translation_text(%SingularTranslation{} = translation, table_name) do
    key = get_key(translation)

    case :ets.lookup(table_name, key) do
      [{^key, text}] -> {:ok, text}
      _ -> :not_found
    end
  end

  def get_all_cached_translations(table_name) do
    :ets.tab2list(table_name)
    |> Enum.map(fn {key, text} -> Tuple.append(key, text) end)
  end

  def cache_translation(%SingularTranslation{text: text} = translation, table_name) do
    key = get_key(translation)
    :ets.insert(table_name, {key, text})
  end

  def delete_cached_translation(%SingularTranslation{} = translation, table_name) do
    key = get_key(translation)
    :ets.delete(table_name, key)
  end

  defp get_key(%SingularTranslation{
         locale: locale,
         domain: domain,
         msgctxt: msgctxt,
         msgid: msgid
       }) do
    {locale, domain, msgctxt, msgid}
  end
end
