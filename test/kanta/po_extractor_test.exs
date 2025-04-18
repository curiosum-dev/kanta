defmodule Kanta.Services.POExtractorTest do
  # Make tests non-concurrent to avoid issues with Mox in Flow processes
  use ExUnit.Case, async: false

  import Mox

  alias Kanta.Services.POExtractor
  alias Kanta.Services.POExtractor.ExtractResult
  alias Kanta.Services.POExtractor.FileResult

  # Set up mocks for data access
  @mock_data_access Kanta.MockDataAccess

  # --- Fixture Paths ---
  @single_messages_dir ["test/fixtures/single_messages"]
  @multi_messages_dir ["test/fixtures/multi_messages"]
  @invalid_po_dir ["test/fixtures/invalid_po"]
  @non_existent_dir ["test/fixtures/non_existent"]
  # Specific path to the invalid PO file
  @invalid_po_file_path Path.join([@invalid_po_dir, "en/LC_MESSAGES/invalid.po"])

  # Define the mock
  Mox.defmock(Kanta.MockDataAccess, for: Kanta.DataAccess)

  setup :verify_on_exit!

  setup do
    # Ensure the required directories exist
    File.mkdir_p!(Path.dirname(@invalid_po_file_path))

    # Create a PO file with invalid syntax for testing error handling
    unless File.exists?(@invalid_po_file_path) do
      invalid_content = """
      msgid "Valid message"
      msgstr "Valid translation"

      # Error starts here: Unclosed quote in msgid
      msgid "This message has an unclosed quote
      msgstr "This translation won't be reached"

      msgstr "This translation appears before its msgid"
      msgid "This msgid appears too late"
      """

      File.write!(@invalid_po_file_path, invalid_content)
    end

    # Since we're using non-concurrent tests, make Mox global
    Mox.set_mox_global()
    :ok
  end

  describe "extract_all_po_messages/3 (Sequential)" do
    test "extracts from single_messages directory (sync)" do
      # Set up expectations for the Italian/Japanese PO files
      @mock_data_access
      |> expect(:create_resource, 9 + 19, fn type, attrs, _opts
                                             when type in [:singular, :plural] ->
        # Return success for all singular translations with a unique ID
        {:ok, Map.put(attrs, :id, System.unique_integer([:positive]))}
      end)

      result =
        POExtractor.extract_po_messages([{@single_messages_dir, @mock_data_access}],
          async: false
        )

      assert %ExtractResult{} = result
      assert result.successful_files == 4
      assert result.failed_files == 0
      assert result.singular_count == 9
      assert result.plural_count == 19
      assert result.skipped_count == 0
      assert Enum.count(result.file_results) == 4
      assert Enum.all?(result.file_results, &(&1.status == :ok))

      # --- Check specific file results ---
      it_default = find_file_result(result, "it/LC_MESSAGES/default.po")
      assert it_default.singular_count == 5
      assert it_default.plural_count == 10

      it_errors = find_file_result(result, "it/LC_MESSAGES/errors.po")
      assert it_errors.singular_count == 1
      assert it_errors.plural_count == 2

      it_interpolations = find_file_result(result, "it/LC_MESSAGES/interpolations.po")
      assert it_interpolations.singular_count == 2
      assert it_interpolations.plural_count == 6

      ja_errors = find_file_result(result, "ja/LC_MESSAGES/errors.po")
      assert ja_errors.singular_count == 1
      assert ja_errors.plural_count == 1
    end

    test "extracts from multi_messages directory (sync)" do
      @mock_data_access
      |> expect(:create_resource, 4, fn :singular, attrs, _opts ->
        {:ok, Map.put(attrs, :id, System.unique_integer([:positive]))}
      end)

      result =
        POExtractor.extract_po_messages([{@multi_messages_dir, @mock_data_access}], async: false)

      assert %ExtractResult{} = result
      assert result.successful_files == 3
      assert result.failed_files == 0
      assert result.singular_count == 4
      assert result.plural_count == 0
      assert result.skipped_count == 0
      assert Enum.count(result.file_results) == 3

      # --- Check specific file results ---
      es_default = find_file_result(result, "es/LC_MESSAGES/default.po")
      assert es_default.singular_count == 1
      assert es_default.plural_count == 0

      it_default = find_file_result(result, "it/LC_MESSAGES/default.po")
      assert it_default.singular_count == 2
      assert it_default.plural_count == 0

      it_errors = find_file_result(result, "it/LC_MESSAGES/errors.po")
      assert it_errors.singular_count == 1
      assert it_errors.plural_count == 0
    end

    test "handles directory with invalid PO file (sync)" do
      # No expectations needed - the file should fail to parse

      result =
        POExtractor.extract_po_messages([{@invalid_po_dir, @mock_data_access}], async: false)

      assert %ExtractResult{} = result
      assert result.successful_files == 0
      assert result.failed_files == 1
      assert result.singular_count == 0
      assert result.plural_count == 0
      assert result.skipped_count == 0
      assert Enum.count(result.file_results) == 1

      file_res = hd(result.file_results)
      assert file_res.path == @invalid_po_file_path
      assert file_res.status == :error
      refute is_nil(file_res.error_reason)
      assert Expo.PO.SyntaxError == file_res.error_reason.__struct__
    end

    test "handles non-existent directory (sync)" do
      result =
        POExtractor.extract_po_messages([{@non_existent_dir, @mock_data_access}],
          async: false
        )

      assert %ExtractResult{} = result
      assert result.successful_files == 0
      assert result.failed_files == 0
      assert result.singular_count == 0
      assert result.plural_count == 0
      assert result.skipped_count == 0
      assert result.file_results == []
    end

    test "filters by allowed_locales (sync)" do
      @mock_data_access
      |> expect(:create_resource, 8 + 18, fn type, attrs, _opts
                                             when type in [:singular, :plural] ->
        # Only Italian translations should be processed
        assert attrs.locale == "it"
        {:ok, Map.put(attrs, :id, System.unique_integer([:positive]))}
      end)

      result =
        POExtractor.extract_po_messages(
          [{@single_messages_dir, @mock_data_access}],
          async: false,
          allowed_locales: ["it"]
        )

      assert %ExtractResult{} = result
      # Only Italian files (3), not Japanese (1)
      assert result.successful_files == 3
      assert result.failed_files == 0
      assert result.singular_count == 8
      assert result.plural_count == 18
      assert result.skipped_count == 0
      assert Enum.count(result.file_results) == 3

      # Verify we have all the Italian files
      assert find_file_result(result, "it/LC_MESSAGES/default.po")
      assert find_file_result(result, "it/LC_MESSAGES/errors.po")
      assert find_file_result(result, "it/LC_MESSAGES/interpolations.po")

      # Japanese files should not be processed
      refute Enum.any?(result.file_results, &String.contains?(&1.path, "ja/LC_MESSAGES"))
    end
  end

  describe "extract_all_po_messages/3 (Async with Flow)" do
    test "extracts from single_messages directory (async)" do
      # Create a counter process to track calls from Flow processes
      counter_pid = spawn_link(fn -> counter_loop(%{singular: 0, plural: 0}) end)

      @mock_data_access
      |> expect(:create_resource, 9 + 19, fn type, attrs, _opts ->
        # Send a message to increment the counter
        case type do
          :singular ->
            send(counter_pid, {:inc, :singular})

          :plural ->
            send(counter_pid, {:inc, :plural})
        end

        {:ok, Map.put(attrs, :id, System.unique_integer([:positive]))}
      end)

      result =
        POExtractor.extract_po_messages([{@single_messages_dir, @mock_data_access}],
          async: true
        )

      # Wait for a moment to ensure all Flow processes complete
      Process.sleep(100)

      # Get the final counts
      send(counter_pid, {:get, self()})

      counts =
        receive do
          {:counts, counts} -> counts
        after
          1000 -> flunk("Timeout waiting for counter results")
        end

      # Verify counts match expectations
      assert counts.singular == 9
      assert counts.plural == 19

      assert %ExtractResult{} = result
      assert result.successful_files == 4
      assert result.failed_files == 0
      assert result.singular_count == 9
      assert result.plural_count == 19
      assert result.skipped_count == 0
      assert Enum.count(result.file_results) == 4
    end

    test "accepts flow options (async)" do
      # Create a counter process
      counter_pid = spawn_link(fn -> counter_loop(%{singular: 0, plural: 0}) end)

      @mock_data_access
      |> expect(:create_resource, 4, fn :singular, attrs, _opts ->
        send(counter_pid, {:inc, :singular})
        {:ok, Map.put(attrs, :id, System.unique_integer([:positive]))}
      end)

      result =
        POExtractor.extract_po_messages(
          [{@multi_messages_dir, @mock_data_access}],
          async: true,
          flow_opts: [stages: 1]
        )

      # Wait for a moment to ensure all Flow processes complete
      Process.sleep(100)

      # Get the final counts
      send(counter_pid, {:get, self()})

      counts =
        receive do
          {:counts, counts} -> counts
        after
          1000 -> flunk("Timeout waiting for counter results")
        end

      # Verify counts match expectations
      assert counts.singular == 4

      assert %ExtractResult{} = result
      assert result.successful_files == 3
      assert result.failed_files == 0
    end
  end

  describe "extract_po_messages_from_file/2" do
    test "extracts simple singular file" do
      path = Path.join([@multi_messages_dir, "es/LC_MESSAGES/default.po"])

      @mock_data_access
      |> expect(:create_resource, 1, fn :singular, attrs, _opts ->
        assert attrs.locale == "es"
        assert attrs.domain == "default"
        assert attrs.msgid == "Hello world"
        assert attrs.msgstr_origin == "Hola mundo"
        {:ok, Map.put(attrs, :id, 1)}
      end)

      result = POExtractor.extract_po_messages_from_file(path, @mock_data_access)

      assert %FileResult{
               path: ^path,
               status: :ok,
               singular_count: 1,
               plural_count: 0,
               skipped_count: 0,
               error_reason: nil
             } = result
    end

    test "handles database errors" do
      path = Path.join([@multi_messages_dir, "es/LC_MESSAGES/default.po"])

      @mock_data_access
      |> expect(:create_resource, 1, fn :singular, _attrs, _opts ->
        {:error, %{errors: [message: "db constraint violation"]}}
      end)

      result = POExtractor.extract_po_messages_from_file(path, @mock_data_access)

      assert %FileResult{
               path: ^path,
               status: :ok,
               singular_count: 0,
               plural_count: 0,
               skipped_count: 1,
               error_reason: nil
             } = result
    end

    test "returns error for invalid PO file content" do
      result = POExtractor.extract_po_messages_from_file(@invalid_po_file_path, @mock_data_access)

      assert %FileResult{
               path: @invalid_po_file_path,
               status: :error,
               singular_count: 0,
               plural_count: 0,
               skipped_count: 0
             } = result

      refute is_nil(result.error_reason)
      assert %Expo.PO.SyntaxError{} = result.error_reason
    end

    test "returns error for non-existent file" do
      non_existent_path = "test/fixtures/non_existent_file.po"
      result = POExtractor.extract_po_messages_from_file(non_existent_path, @mock_data_access)

      assert %FileResult{
               path: ^non_existent_path,
               status: :error,
               singular_count: 0,
               plural_count: 0,
               skipped_count: 0,
               error_reason: :enoent
             } = result
    end
  end

  # Helper to find a specific FileResult in the ExtractResult list by path suffix
  defp find_file_result(%ExtractResult{file_results: results}, path_suffix) do
    Enum.find(results, fn %FileResult{path: p} -> String.ends_with?(p, path_suffix) end) ||
      raise "FileResult ending with '#{path_suffix}' not found in results"
  end

  # Helper function for counter process
  defp counter_loop(state) do
    receive do
      {:inc, key} ->
        counter_loop(Map.update(state, key, 1, &(&1 + 1)))

      {:get, caller} ->
        send(caller, {:counts, state})
        counter_loop(state)
    end
  end
end
