defmodule Kanta.PoFiles.Services.StaleDetection do
  @moduledoc """
  Service for detecting stale translation messages and finding potential replacements.

  A message is "stale" when it exists in the database but is missing from ALL locale
  PO files. This service identifies these stale messages system-wide and uses fuzzy
  matching (Jaro distance algorithm) to suggest active messages that could replace them.

  ## Stale Detection Strategy

  Uses a system-wide approach that treats messages globally rather than per-locale:

  1. Extracts all message keys from PO files across all locales
  2. Compares database messages against this global set of active keys
  3. Messages not found in ANY locale's PO files are marked as stale
  4. Fuzzy matching finds similar active messages within the same domain/context

  This global approach ensures cross-locale consistency and simplifies migration
  when message keys change across the entire application.

  ## Fuzzy Matching

  When stale messages are detected, the service automatically searches for similar
  active messages using String.jaro_distance (0.0 = no match, 1.0 = identical).
  Matches are scoped by domain and context for relevance, with a default threshold
  of 0.8 for determining viable replacements.

  ## Usage

      # Detect stale messages with default settings
      StaleDetection.call()

      # Use custom PO file path and threshold
      StaleDetection.call(base_path: "/path/to/gettext", fuzzy_threshold: 0.9)

  ## Returns

  Returns `{:ok, %Result{}}` containing:
  - `stale_message_ids` - MapSet of stale message IDs
  - `fuzzy_matches_map` - Map of stale_message_id => %FuzzyMatch{}
  - `stale_count` - Total number of stale messages
  - `mergeable_count` - Number of stale messages with fuzzy matches above threshold

  Each FuzzyMatch struct contains:
  - `stale_message_id` - ID of the stale message
  - `matched_message_id` - ID of the active message that matches
  - `matched_msgid` - The msgid string of the matched message
  - `similarity_score` - Jaro distance score (0.0-1.0)
  """

  alias Kanta.Translations.Message
  alias Kanta.PoFiles.POFileParser
  alias Kanta.PoFiles.Services.ExtractMessage
  alias Kanta.PoFiles.Services.StaleDetection.Result
  alias Kanta.PoFiles.Services.StaleDetection.FuzzyMatch

  alias Kanta.Translations

  @default_fuzzy_threshold 0.8

  @doc """
  Identifies stale translation messages system-wide.

  A message is considered "stale" if it doesn't exist in ANY locale's PO files.

  ## Options

    * `:base_path` - Base directory to search for PO files (optional)
    * `:fuzzy_threshold` - Similarity threshold 0.0-1.0 (default: 0.8)

  ## Returns

  `{:ok, %Result{}}` - A struct containing:
    * `:stale_message_ids` - MapSet of message IDs that are stale
    * `:fuzzy_matches_map` - Map of stale_message_id => %FuzzyMatch{}
    * `:stale_count` - Total number of stale messages
    * `:mergeable_count` - Number of stale messages with fuzzy matches above threshold

  """
  def call(opts \\ [])

  # Support old API: call(string_path)
  def call(base_path) when is_binary(base_path) do
    call(base_path: base_path)
  end

  def call(opts) when is_list(opts) do
    base_path = Keyword.get(opts, :base_path, get_default_base_path())
    threshold = Keyword.get(opts, :fuzzy_threshold, @default_fuzzy_threshold)

    # 1. Extract active message keys from ALL locales' PO files
    # Format: {msgid, domain, context}
    po_keys = POFileParser.extract_message_keys(base_path)
    normalized_po_keys = normalize_po_keys(po_keys)

    # 2. Get all messages from database
    db_messages = list_all_db_messages()

    # 3. Partition into matched and stale messages
    {matched_messages, stale_messages} = partition_messages(db_messages, normalized_po_keys)

    stale_messages_ids = get_stale_messages_ids(stale_messages)

    # 4. Compute fuzzy matches for stale messages
    fuzzy_matches_map = compute_fuzzy_matches_map(matched_messages, stale_messages, threshold)

    result =
      Result.new(stale_messages_ids, fuzzy_matches_map)

    {:ok, result}
  end

  ## Configuration & Setup

  # Returns the default base path to the priv/gettext directory
  defp get_default_base_path do
    otp_name = Kanta.config().otp_name

    :code.priv_dir(otp_name)
    |> to_string()
    |> Path.join("gettext")
  end

  ## Database Operations

  # Retrieves all messages from database with domain and context preloaded
  defp list_all_db_messages do
    Translations.list_all_messages(preloads: [:domain, :context])
  end

  ## PO File Processing

  # Normalizes PO keys by applying default domain and context values
  defp normalize_po_keys(po_keys) do
    Enum.map(po_keys, fn {msgid, domain, context} ->
      normalized_domain = domain || ExtractMessage.default_domain()
      normalized_context = context || ExtractMessage.default_context()
      {msgid, normalized_domain, normalized_context}
    end)
    |> MapSet.new()
  end

  ## Message Partitioning

  # Partitions database messages into matched (active) and stale messages
  defp partition_messages(db_messages, active_keys) do
    Enum.split_with(db_messages, fn message ->
      key = message_to_key(message)
      MapSet.member?(active_keys, key)
    end)
  end

  # Converts a message struct to its unique key tuple {msgid, domain, context}
  defp message_to_key(%Message{} = message) do
    %Message{msgid: msgid, domain: domain, context: context} = message
    domain_name = domain && domain.name
    context_name = context && context.name
    {msgid, domain_name, context_name}
  end

  # Extracts message IDs from stale messages into a MapSet
  defp get_stale_messages_ids(stale_messages) when is_list(stale_messages) do
    stale_messages
    |> Enum.map(fn %Message{id: id} -> id end)
    |> MapSet.new()
  end

  ## Fuzzy Matching

  # Computes fuzzy matches map for stale messages against active messages
  defp compute_fuzzy_matches_map(matched_messages, stale_messages, threshold) do
    if stale_messages == [] do
      %{}
    else
      fuzzy_matches = fuzzy_match(stale_messages, matched_messages, threshold)

      Map.new(fuzzy_matches, fn {stale_message, matched_message, score} ->
        fuzzy_match =
          FuzzyMatch.new(
            stale_message.id,
            matched_message.id,
            matched_message.msgid,
            score
          )

        {stale_message.id, fuzzy_match}
      end)
    end
  end

  # Finds fuzzy matches between stale and active messages using Jaro distance, scoped by domain/context
  defp fuzzy_match(messages, against_messages, threshold)
       when is_list(messages) and is_list(against_messages) do
    scoped_against_messages =
      Enum.group_by(against_messages, fn %Message{} = message ->
        {message.domain, message.context}
      end)

    messages
    |> Enum.map(fn %Message{} = message ->
      case fuzzy_match_message(message, scoped_against_messages, threshold) do
        :empty ->
          nil

        {:ok, {against_message, score}} ->
          {message, against_message, score}
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  # Finds the best fuzzy match for a single message within its domain/context scope
  defp fuzzy_match_message(%Message{} = message, scoped_against_messages, threshold)
       when is_map(scoped_against_messages) do
    against_messages = scoped_against_messages[{message.domain, message.context}] || []

    against_messages
    |> Enum.reduce_while(nil, &reduce_fuzzy_match(message, &1, &2, threshold))
    |> wrap_fuzzy_result()
  end

  # Reduces fuzzy matches by comparing each candidate against the best match so far
  defp reduce_fuzzy_match(%Message{} = message, %Message{} = against_message, acc, threshold) do
    score = String.jaro_distance(message.msgid, against_message.msgid)
    update_best_match(against_message, score, acc, threshold)
  end

  # Updates the best match based on the current score and threshold (when accumulator exists)
  defp update_best_match(against_message, score, acc, _threshold) when not is_nil(acc) do
    {_, acc_score} = acc

    cond do
      score == 1.0 -> {:halt, {against_message, score}}
      acc_score < score -> {:cont, {against_message, score}}
      true -> {:cont, acc}
    end
  end

  # Updates the best match based on the current score and threshold (first candidate)
  defp update_best_match(against_message, score, acc, threshold) when is_nil(acc) do
    cond do
      score == 1.0 -> {:halt, {against_message, score}}
      score >= threshold -> {:cont, {against_message, score}}
      true -> {:cont, acc}
    end
  end

  # Wraps the fuzzy match result in the appropriate format
  defp wrap_fuzzy_result(nil), do: :empty
  defp wrap_fuzzy_result(result), do: {:ok, result}
end
