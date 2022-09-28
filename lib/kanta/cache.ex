defmodule Kanta.Cache do
  alias Kanta.Cache.Agent

  defdelegate get_cached_translation_text(translation), to: Agent
  defdelegate get_all_cached_translations, to: Agent
  defdelegate cache_translation(translation), to: Agent
  defdelegate delete_cached_translation(translation), to: Agent
end
