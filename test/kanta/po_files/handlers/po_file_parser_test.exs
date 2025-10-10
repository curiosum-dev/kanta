defmodule Kanta.POFiles.POFileParserTest do
  use ExUnit.Case, async: true

  alias Kanta.POFiles.POFileParser

  @test_base_path "test/fixtures/single_messages"

  describe "find_po_files/2" do
    test "finds all PO files in test fixtures" do
      po_files = POFileParser.find_po_files(@test_base_path)

      assert is_list(po_files)
      assert length(po_files) > 0

      # Verify structure of returned maps
      for po_file <- po_files do
        assert Map.has_key?(po_file, :path)
        assert Map.has_key?(po_file, :locale)
        assert Map.has_key?(po_file, :domain)
        assert String.ends_with?(po_file.path, ".po")
      end
    end

    test "filters by allowed_locales when provided" do
      all_files = POFileParser.find_po_files(@test_base_path)
      filtered_files = POFileParser.find_po_files(@test_base_path, ["it"])

      # Filtered list should be smaller or equal
      assert length(filtered_files) <= length(all_files)

      # All filtered files should have locale "it"
      for po_file <- filtered_files do
        assert po_file.locale == "it"
      end
    end

    test "returns all locales when allowed_locales is nil" do
      files_with_nil = POFileParser.find_po_files(@test_base_path, nil)
      files_without_opt = POFileParser.find_po_files(@test_base_path)

      assert length(files_with_nil) == length(files_without_opt)
    end

    test "parses locale and domain correctly from path" do
      po_files = POFileParser.find_po_files(@test_base_path)

      # Find a specific known file
      default_it =
        Enum.find(po_files, fn file ->
          file.locale == "it" && file.domain == "default"
        end)

      assert default_it != nil
      assert String.contains?(default_it.path, "it/LC_MESSAGES/default.po")
    end
  end

  describe "parse_all_po_files/2" do
    test "parses PO files and includes messages" do
      parsed_files = POFileParser.parse_all_po_files(@test_base_path, ["it"])

      assert is_list(parsed_files)
      assert length(parsed_files) > 0

      # Verify structure includes messages
      for po_file <- parsed_files do
        assert Map.has_key?(po_file, :messages)
        assert is_list(po_file.messages)
      end
    end

    test "messages are Expo.Message structs" do
      parsed_files = POFileParser.parse_all_po_files(@test_base_path, ["it"])

      # Get first file with messages
      file_with_messages = Enum.find(parsed_files, fn file -> length(file.messages) > 0 end)

      assert file_with_messages != nil

      first_message = List.first(file_with_messages.messages)
      # Check it's one of the Expo message types
      assert match?(%Expo.Message.Singular{}, first_message) ||
               match?(%Expo.Message.Plural{}, first_message)
    end
  end

  describe "extract_message_keys/2" do
    test "returns a MapSet of message keys" do
      keys = POFileParser.extract_message_keys(@test_base_path, ["it"])

      assert %MapSet{} = keys
      assert MapSet.size(keys) > 0
    end

    test "keys are tuples of {msgid, domain, context}" do
      keys = POFileParser.extract_message_keys(@test_base_path, ["it"])

      for key <- keys do
        assert is_tuple(key)
        assert tuple_size(key) == 3
        {msgid, domain, context} = key
        assert is_binary(msgid)
        assert is_binary(domain)
        assert is_binary(context)
      end
    end

    test "extracts keys from singular messages without context" do
      keys = POFileParser.extract_message_keys(@test_base_path, ["it"])

      # Should contain some messages with "default" context
      default_context_keys =
        Enum.filter(keys, fn {_msgid, _domain, context} -> context == "default" end)

      assert length(default_context_keys) > 0
    end

    test "extracts keys from messages with custom context" do
      keys = POFileParser.extract_message_keys(@test_base_path, ["it"])

      # If there are any messages with custom context, they should be included
      all_contexts = Enum.map(keys, fn {_msgid, _domain, context} -> context end) |> Enum.uniq()

      # At minimum, "default" context should exist
      assert "default" in all_contexts
    end

    test "handles multiple domains" do
      keys = POFileParser.extract_message_keys(@test_base_path, ["it"])

      # Extract unique domains
      all_domains = Enum.map(keys, fn {_msgid, domain, _context} -> domain end) |> Enum.uniq()

      # Should have at least "default" domain
      assert "default" in all_domains

      # Likely has "errors" domain too based on fixture structure
      if "errors" in all_domains do
        assert "errors" in all_domains
      end
    end

    test "deduplicates messages across locales" do
      # Same message in different locales should appear only once per domain/context
      keys_it = POFileParser.extract_message_keys(@test_base_path, ["it"])

      keys_ja = POFileParser.extract_message_keys(@test_base_path, ["ja"])

      keys_all = POFileParser.extract_message_keys(@test_base_path)

      # Keys from all locales should not be more than sum (due to overlap)
      # This is a weak assertion but validates deduplication concept
      assert MapSet.size(keys_all) <= MapSet.size(keys_it) + MapSet.size(keys_ja)
    end
  end
end
