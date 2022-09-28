defmodule Kanta.POFiles do
  alias Kanta.POFiles.ExtractorAgent

  defdelegate get_translations, to: ExtractorAgent
end
