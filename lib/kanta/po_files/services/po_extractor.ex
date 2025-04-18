defmodule Kanta.Services.POExtractor do
  @moduledoc """
  Extracts translations from PO files and stores them in the database.

  Provides both sequential and parallel (Flow-based) methods for processing.
  """

  alias Expo.Messages
  alias Expo.Message
  alias Expo.PO
  alias Flow

  require Logger

  @po_wildcard "*/LC_MESSAGES/*.po"

  defmodule FileResult do
    @type t :: %__MODULE__{
            path: String.t(),
            status: :ok | :error,
            singular_count: non_neg_integer(),
            plural_count: non_neg_integer(),
            skipped_count: non_neg_integer(),
            error_reason: any()
          }

    defstruct [
      :path,
      :status,
      singular_count: 0,
      plural_count: 0,
      skipped_count: 0,
      error_reason: nil
    ]
  end

  defmodule ExtractResult do
    @type t :: %__MODULE__{
            successful_files: non_neg_integer(),
            failed_files: non_neg_integer(),
            singular_count: non_neg_integer(),
            plural_count: non_neg_integer(),
            skipped_count: non_neg_integer(),
            file_results: [FileResult.t()]
          }

    defstruct successful_files: 0,
              failed_files: 0,
              singular_count: 0,
              plural_count: 0,
              skipped_count: 0,
              file_results: []
  end

  @doc """
  Extracts all messages from PO files and stores them in the database.

  ## Parameters
    * `dirs_data_access` - List of tuples containing {directory, data_access_module}
      where directory contains PO files and data_access_module handles database operations
    * `opts` - Options for extraction:
      * `:async` - Boolean flag to use parallel processing (default: false)
      * `:flow_opts` - Options passed to Flow when using async mode
      * `:allowed_locales` - List of locale codes to process (default: empty list, which processes all)

  ## Returns
    An `ExtractResult` struct containing counts of processed messages and file results.

  ## Examples

      # Extract translations synchronously
      iex> Kanta.Services.POExtractor.extract_po_messages([{"priv/gettext", MyApp.DataAccess}])
      %Kanta.Services.POExtractor.ExtractResult{...}

      # Extract translations asynchronously with custom Flow options
      iex> Kanta.Services.POExtractor.extract_po_messages([{"custom/path", MyApp.DataAccess}], async: true, flow_opts: [max_demand: 5])
      %Kanta.Services.POExtractor.ExtractResult{...}

      # Extract translations only for specified locales
      iex> Kanta.Services.POExtractor.extract_po_messages([{"custom/path", MyApp.DataAccess}], allowed_locales: ["en", "fr"])
      %Kanta.Services.POExtractor.ExtractResult{...}
  """
  @spec extract_po_messages(list({String.t(), module()}), keyword()) ::
          ExtractResult.t()
  def extract_po_messages(dirs_data_access, opts \\ []) when is_list(dirs_data_access) do
    # Extract options using pattern matching with defaults
    %{
      async: async?,
      flow_opts: flow_opts,
      allowed_locales: allowed_locales
    } = parse_opts(opts)

    # Get all PO files with their data access modules
    paths_with_data_access = collect_po_files(dirs_data_access, allowed_locales)

    # Choose processing method based on async setting
    case async? do
      true -> extract_all_po_messages_async(paths_with_data_access, flow_opts)
      false -> extract_all_po_messages_sequential(paths_with_data_access)
    end
  end

  # Private helper function to collect and filter PO files
  defp collect_po_files(dirs_data_access, allowed_locales) do
    Enum.flat_map(dirs_data_access, fn {backend_priv_dir, data_access} ->
      backend_priv_dir
      |> find_all_po_files()
      |> maybe_restrict_locales(allowed_locales)
      |> Enum.map(fn path -> {path, data_access} end)
    end)
  end

  defp parse_opts(opts) do
    [async: false, flow_opts: [], allowed_locales: []]
    |> Keyword.merge(opts)
    |> Map.new()
  end

  @doc """
  Extracts messages from a single PO file path.
  Used by the sequential version. Raises error on parse failure.

  ## Returns
    A FileResult struct containing counts for singular, plural, and skipped translations.
  """
  @spec extract_po_messages_from_file(String.t(), module()) ::
          {:ok, FileResult.t()}
          | {:error, Expo.PO.SyntaxError.t() | Expo.PO.DuplicateMessagesError.t() | File.posix()}
  def extract_po_messages_from_file(path, data_access) do
    try do
      case PO.parse_file(path, strip_meta: true) do
        {:ok, %Messages{messages: messages}} ->
          {locale, domain} = locale_and_domain_from_path(path)
          # Filter out obsolete messages
          messages = Enum.reject(messages, & &1.obsolete)

          # Initialize result with zeroed counts
          result = %FileResult{path: path, status: :ok}

          # Process messages and accumulate counts
          Enum.reduce(messages, result, fn message, acc ->
            process_message(data_access, message, locale, domain, acc)
          end)

        {:error, reason} ->
          Logger.error("Failed to parse PO file #{path}: #{inspect(reason)}")

          %FileResult{
            path: path,
            status: :error,
            error_reason: reason
          }
      end
    rescue
      exception ->
        Logger.error(
          "Unexpected error processing file #{path}: #{inspect(exception)} \n #{Exception.format_stacktrace(__STACKTRACE__)}"
        )

        %FileResult{
          path: path,
          status: :error,
          error_reason: exception
        }
    end
  end

  @spec extract_all_po_messages_async(list({String.t(), module()}), keyword()) ::
          ExtractResult.t()
  defp extract_all_po_messages_async(po_files_paths, flow_opts) do
    po_files_paths
    |> Flow.from_enumerable(flow_opts)
    |> Flow.partition(key: {:elem, 1})
    |> Flow.map(fn {path, data_access} -> extract_po_messages_from_file(path, data_access) end)
    |> Enum.to_list()
    |> Enum.reduce(%ExtractResult{}, &aggregate_result/2)

    # List.first extracts the inner list: [%ExtractResult{...}]
    # We need one more step to get the struct itself
  end

  @spec extract_all_po_messages_sequential(list({String.t(), module()})) ::
          ExtractResult.t()
  defp extract_all_po_messages_sequential(paths_data_access) do
    paths_data_access
    |> Enum.map(fn {path, data_access} -> extract_po_messages_from_file(path, data_access) end)
    |> Enum.reduce(%ExtractResult{}, &aggregate_result/2)
  end

  # Reject paths with locales not in the allowed list.
  defp maybe_restrict_locales(paths, []), do: paths

  defp maybe_restrict_locales(paths, allowed_locales) do
    Enum.reject(paths, fn path ->
      {locale, _domain} = locale_and_domain_from_path(path)
      not Enum.member?(allowed_locales, locale)
    end)
  end

  # Process a  singular message
  defp process_message(data_access, %Message.Singular{} = message, locale, domain, result) do
    msgid = IO.iodata_to_binary(message.msgid)
    msgstr = IO.iodata_to_binary(message.msgstr)
    msgctxt = message.msgctxt && IO.iodata_to_binary(message.msgctxt)

    case data_access.create_resource(
           :singular,
           %{
             locale: locale,
             domain: domain,
             msgctxt: msgctxt,
             msgid: msgid,
             msgstr_origin: msgstr
           },
           []
         ) do
      {:ok, translation} ->
        Logger.debug("Added #{inspect(translation)}")
        %{result | singular_count: result.singular_count + 1}

      {:error, changeset} ->
        # Log DB errors
        Logger.warning(
          "DB insert failed (singular) for #{locale}/#{domain} msgid '#{msgid}': #{inspect(changeset.errors)}"
        )

        %{result | skipped_count: result.skipped_count + 1}
    end
  end

  # Process a plural message
  defp process_message(data_access, %Message.Plural{} = message, locale, domain, result) do
    msgid = IO.iodata_to_binary(message.msgid)
    msgid_plural = IO.iodata_to_binary(message.msgid_plural)
    msgctxt = message.msgctxt && IO.iodata_to_binary(message.msgctxt)

    # Process each plural form
    Enum.reduce(message.msgstr, result, fn {plural_index, plural_str}, current_result ->
      plural_str = IO.iodata_to_binary(plural_str)

      case data_access.create_resource(
             :plural,
             %{
               locale: locale,
               domain: domain,
               msgctxt: msgctxt,
               msgid: msgid,
               msgid_plural: msgid_plural,
               plural_index: plural_index,
               msgstr: nil,
               msgstr_origin: plural_str
             },
             []
           ) do
        {:ok, translation} ->
          Logger.debug("Added #{inspect(translation)}")
          %{current_result | plural_count: current_result.plural_count + 1}

        {:error, changeset} ->
          Logger.warning(
            "DB insert failed (plural form #{plural_index}) for #{locale}/#{domain} msgid '#{msgid}': #{inspect(changeset.errors)}"
          )

          %{current_result | skipped_count: current_result.skipped_count + 1}
      end
    end)
  end

  # Aggregates individual file results into the overall extract result
  defp aggregate_result(file_result, acc) do
    # Add the file result to our list (prepending for efficiency)
    updated_acc = %{acc | file_results: [file_result | acc.file_results]}

    case file_result.status do
      :ok ->
        %{
          updated_acc
          | successful_files: acc.successful_files + 1,
            singular_count: acc.singular_count + file_result.singular_count,
            plural_count: acc.plural_count + file_result.plural_count,
            skipped_count: acc.skipped_count + file_result.skipped_count
        }

      :error ->
        %{updated_acc | failed_files: acc.failed_files + 1}
    end
  end

  @spec find_all_po_files(String.t()) :: [String.t()]
  defp find_all_po_files(dir) do
    dir
    |> Path.join(@po_wildcard)
    |> Path.wildcard()
  end

  defp locale_and_domain_from_path(path) do
    [file, "LC_MESSAGES", locale | _rest] = path |> Path.split() |> Enum.reverse()
    domain = Path.rootname(file, ".po")
    {locale, domain}
  end
end
