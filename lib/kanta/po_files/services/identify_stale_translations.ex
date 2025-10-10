defmodule Kanta.POFiles.Services.IdentifyStaleTranslations do
  @moduledoc """
  Identifies translation messages that exist in DB but not in PO files.

  This service compares all messages stored in the database against the messages
  currently present in PO files across ALL locales. A message is considered "stale"
  if it doesn't exist in ANY locale's PO files.

  ## Usage

      iex> IdentifyStaleTranslations.call()
      {:ok, %{
        stale_message_ids: #MapSet<[1, 2, 3]>,
        active_keys: #MapSet<[...]>,
        stats: %{
          total_db_messages: 100,
          stale_count: 3,
          active_count: 97
        }
      }}

  """

  alias Kanta.POFiles.POFileParser
  alias Kanta.Translations

  @doc """
  Identifies stale translation messages system-wide (across all locales).

  A message is considered "stale" if it doesn't exist in ANY locale's PO files.

  ## Arguments

    * `base_path` - Optional. Base directory to search for PO files.
      If not provided, uses Kanta config to determine path.

  ## Returns

  `{:ok, map}` where map contains:
    * `:stale_message_ids` - MapSet of message IDs that are stale
    * `:active_keys` - MapSet of active message keys from all PO files
    * `:stats` - Statistics about the analysis

  """
  def call(base_path \\ nil) do
    # 1. Get base path (from args or config)
    base_path = base_path || get_default_base_path()

    # 2. Extract active message keys from ALL locales' PO files
    active_keys = POFileParser.extract_message_keys(base_path)

    # 3. Get all messages from database
    db_messages = list_all_db_messages()

    # 4. Identify stale message IDs
    stale_message_ids = identify_stale_message_ids(db_messages, active_keys)

    {:ok,
     %{
       stale_message_ids: stale_message_ids,
       active_keys: active_keys,
       stats: %{
         total_db_messages: length(db_messages),
         stale_count: MapSet.size(stale_message_ids),
         active_count: MapSet.size(active_keys)
       }
     }}
  end

  # Private functions

  defp get_default_base_path do
    otp_name = Kanta.config().otp_name

    :code.priv_dir(otp_name)
    |> to_string()
    |> Path.join("gettext")
  end

  defp list_all_db_messages do
    Translations.list_all_messages(preloads: [:domain, :context])
  end

  defp identify_stale_message_ids(db_messages, active_keys) do
    db_messages
    |> Enum.reject(fn message ->
      domain_name = if message.domain, do: message.domain.name, else: nil
      context_name = if message.context, do: message.context.name, else: "default"

      key = {message.msgid, domain_name, context_name}
      MapSet.member?(active_keys, key)
    end)
    |> Enum.map(& &1.id)
    |> MapSet.new()
  end
end
