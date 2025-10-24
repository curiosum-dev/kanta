defmodule Kanta.PoFiles.Services.StaleDetection.Result do
  @moduledoc """
  Result struct for stale translation detection.

  Contains information about stale messages and their fuzzy matches.

  ## Terminology

  - **fuzzy_matches_map**: Map of stale message IDs to their FuzzyMatch structs
  - **mergeable_count**: User-facing count of messages that can be automatically merged
  """

  alias Kanta.PoFiles.Services.StaleDetection.FuzzyMatch

  @type t :: %__MODULE__{
          stale_message_ids: MapSet.t(integer()),
          fuzzy_matches_map: %{integer() => FuzzyMatch.t()},
          stale_count: integer(),
          mergeable_count: integer()
        }

  defstruct [
    :stale_message_ids,
    :fuzzy_matches_map,
    :stale_count,
    :mergeable_count
  ]

  @spec new(
          stale_message_ids :: MapSet.t(integer()),
          fuzzy_matches_map :: %{integer() => FuzzyMatch.t()}
        ) :: __MODULE__.t()
  def new(stale_message_ids, fuzzy_matches_map) do
    %__MODULE__{
      stale_message_ids: stale_message_ids,
      fuzzy_matches_map: fuzzy_matches_map,
      stale_count: MapSet.size(stale_message_ids),
      mergeable_count: map_size(fuzzy_matches_map)
    }
  end
end
