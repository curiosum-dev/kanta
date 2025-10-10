defmodule Kanta.POFiles.POFileParser do
  @moduledoc """
  Shared logic for parsing PO files and extracting message data.
  Used by both sync (MessagesExtractor) and stale detection.
  """

  @po_wildcard "**/*.po"
  @default_context "default"

  alias Expo.{Messages, PO}

  @doc """
  Finds all PO files in the given base directory.

  ## Arguments

    * `base_path` - Base directory to search for PO files (e.g., "/path/to/priv/gettext" or "test/fixtures")
    * `allowed_locales` - Optional list of locale codes to filter by (e.g., ["en", "pl"])

  ## Returns

  List of maps with keys:
    * `:path` - Full path to the PO file
    * `:locale` - Locale code (e.g., "en", "pl")
    * `:domain` - Domain name (e.g., "default", "errors")

  ## Examples

      iex> POFileParser.find_po_files("/path/to/priv/gettext")
      [
        %{path: "/path/to/priv/gettext/en/LC_MESSAGES/default.po", locale: "en", domain: "default"},
        %{path: "/path/to/priv/gettext/pl/LC_MESSAGES/default.po", locale: "pl", domain: "default"}
      ]

      iex> POFileParser.find_po_files("/path/to/priv/gettext", ["en"])
      [
        %{path: "/path/to/priv/gettext/en/LC_MESSAGES/default.po", locale: "en", domain: "default"}
      ]

  """
  def find_po_files(base_path, allowed_locales \\ nil) do
    base_path
    |> Path.join(@po_wildcard)
    |> Path.wildcard()
    |> Enum.map(&parse_po_file_path/1)
    |> maybe_restrict_locales(allowed_locales)
  end

  @doc """
  Parses all PO files and returns messages with metadata.

  ## Arguments

    * `base_path` - Base directory to search for PO files
    * `allowed_locales` - Optional list of locale codes to filter by

  ## Returns

  List of maps with keys:
    * `:path` - Full path to the PO file
    * `:locale` - Locale code
    * `:domain` - Domain name
    * `:messages` - List of `Expo.Message` structs

  ## Examples

      iex> POFileParser.parse_all_po_files("/path/to/priv/gettext")
      [
        %{
          path: "/path/to/en/default.po",
          locale: "en",
          domain: "default",
          messages: [%Expo.Message.Singular{...}, ...]
        }
      ]

  """
  def parse_all_po_files(base_path, allowed_locales \\ nil) do
    find_po_files(base_path, allowed_locales)
    |> Enum.map(fn po_file ->
      %Messages{messages: messages} = PO.parse_file!(po_file.path)
      Map.put(po_file, :messages, messages)
    end)
  end

  @doc """
  Extracts just the message keys for stale detection.

  Returns a MapSet of tuples: {msgid, domain, context}

  ## Arguments

    * `base_path` - Base directory to search for PO files
    * `allowed_locales` - Optional list of locale codes to filter by

  ## Examples

      iex> POFileParser.extract_message_keys("/path/to/priv/gettext")
      #MapSet<[
        {"Welcome", "default", "default"},
        {"Hello %{name}", "default", "greetings"},
        {"Error occurred", "errors", "default"}
      ]>

  """
  def extract_message_keys(base_path, allowed_locales \\ nil) do
    parse_all_po_files(base_path, allowed_locales)
    |> Enum.flat_map(fn %{domain: domain, messages: messages} ->
      Enum.map(messages, &extract_key_from_message(&1, domain))
    end)
    |> MapSet.new()
  end

  # Private helpers

  defp parse_po_file_path(path) do
    [file, "LC_MESSAGES", locale | _rest] = path |> Path.split() |> Enum.reverse()
    domain = Path.rootname(file, ".po")
    %{locale: locale, domain: domain, path: path}
  end

  defp maybe_restrict_locales(po_files, nil), do: po_files

  defp maybe_restrict_locales(po_files, allowed_locales) when is_list(allowed_locales) do
    allowed_set = MapSet.new(Enum.map(allowed_locales, &to_string/1))
    Enum.filter(po_files, &MapSet.member?(allowed_set, &1.locale))
  end

  defp extract_key_from_message(message, domain) do
    case message do
      %Expo.Message.Singular{msgid: msgid, msgctxt: nil} ->
        {Enum.join(msgid), domain, @default_context}

      %Expo.Message.Singular{msgid: msgid, msgctxt: [ctx]} ->
        {Enum.join(msgid), domain, ctx}

      %Expo.Message.Plural{msgid_plural: msgid, msgctxt: nil} ->
        {Enum.join(msgid), domain, @default_context}

      %Expo.Message.Plural{msgid_plural: msgid, msgctxt: [ctx]} ->
        {Enum.join(msgid), domain, ctx}
    end
  end
end
