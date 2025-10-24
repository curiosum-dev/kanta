defmodule Kanta.PoFiles.Services.StaleDetection.FuzzyMatch do
  @moduledoc """
  Represents a fuzzy match between a stale message and an active message.

  This struct contains information about a potential replacement for a stale message,
  including the similarity score and identifiers for both messages.
  """

  @type t :: %__MODULE__{
          stale_message_id: integer(),
          matched_message_id: integer(),
          matched_msgid: String.t(),
          similarity_score: float()
        }

  defstruct [
    :stale_message_id,
    :matched_message_id,
    :matched_msgid,
    :similarity_score
  ]

  @doc """
  Creates a new FuzzyMatch struct.

  ## Parameters

    * `stale_message_id` - ID of the stale message
    * `matched_message_id` - ID of the active message that matches
    * `matched_msgid` - The msgid string of the matched message
    * `similarity_score` - Jaro distance score (0.0-1.0)

  """
  @spec new(
          stale_message_id :: integer(),
          matched_message_id :: integer(),
          matched_msgid :: String.t(),
          similarity_score :: float()
        ) :: t()
  def new(stale_message_id, matched_message_id, matched_msgid, similarity_score) do
    %__MODULE__{
      stale_message_id: stale_message_id,
      matched_message_id: matched_message_id,
      matched_msgid: matched_msgid,
      similarity_score: similarity_score
    }
  end
end
