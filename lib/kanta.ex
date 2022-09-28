defmodule Kanta do
  @moduledoc """
  Documentation for `Kanta`.
  """

  alias Kanta.Gettext
  alias Kanta.CacheAgent
  # alias Kanta.Storage

  defdelegate get_languages, to: Gettext

  # @doc """
  # Returns translations from .po files, replaced with cached versions if exist.
  # """
  # def get_translations(language) do
  #   Gettext.get_translations(language)
  #   |> Enum.map(fn {locale, domain, msgctxt, msgid, translated} ->
  #     case CacheAgent.get_cached_translation(locale, domain, msgctxt, msgid) do
  #       :not_found -> {locale, domain, msgctxt, msgid, translated}
  #       {:ok, cached_translation} -> {locale, domain, msgctxt, msgid, cached_translation}
  #     end
  #   end)
  # end

  # def set_translation(locale, domain, msgctxt, msgid, translated) when is_binary(translated) do
  #   case String.length(translated) do
  #     0 ->
  #       Storage.delete_stored_translation(locale, domain, msgctxt, msgid)
  #       CacheAgent.delete_cached_translation(locale, domain, msgctxt, msgid)

  #     _ ->
  #       Storage.store_translation(locale, domain, msgctxt, msgid, translated)
  #       CacheAgent.cache_translation(locale, domain, msgctxt, msgid, translated)
  #   end
  # end
end
