defmodule Kanta.POFiles.POExtractorTask do
  @moduledoc """
  Task module responsible for extracting PO (Portable Object) message files for internationalization.

  This module provides functionality to:
  - Extract PO messages from specified directories or modules implementing the `Kanta.Backend` behavior
  - Process different input formats for extraction paths
  - List all PO directories from registered Kanta backends

  It's designed to be run as a Task that performs the extraction operation as defined by provided options.

  ## Usage

  In the `application.ex` file, you can start the task with the following code:

  ```elixir
  children = [
    {Kanta.POFiles.POExtractorTask, extract_paths: [{"priv/gettext", MyApp.SomeDataAccess}]),
    ...
    ]
  ```

  where:

  - `[{"priv/gettext", MyApp.SomeDataAccess}])` - list of tuples {directory_with_po_files, Kanta data access implementation module}

  """

  require Logger

  alias Kanta.Services.POExtractor

  use Task

  def start_link(opts \\ []) do
    Task.start_link(fn -> run(opts) end)
  end

  def run(opts) do
    allowed_locales = []
    extended_opts = Keyword.merge(opts, allowed_locales: allowed_locales)

    inputs = Keyword.get(opts, :extract_paths, [])

    dirs_data_access =
      Enum.reduce(inputs, [], fn
        {dir, data_access_module}, acc when is_binary(dir) ->
          [{dir, data_access_module} | acc]

        {backend_module, data_access_module}, acc when is_atom(backend_module) ->
          dir = get_priv_dir(backend_module)
          if dir, do: [{dir, data_access_module} | acc], else: acc

        {backend_module, data_access_module}, acc when is_atom(backend_module) ->
          dir = get_priv_dir(backend_module)
          if dir, do: [{dir, data_access_module} | acc], else: acc

        backend_module, acc when is_atom(backend_module) ->
          default_data_access = Keyword.fetch!(opts, :default_data_access)
          dir = get_priv_dir(backend_module)
          if dir, do: [{dir, default_data_access} | acc], else: acc

        dir, acc when is_binary(dir) ->
          default_data_access = Keyword.fetch!(opts, :default_data_access)
          [{dir, default_data_access} | acc]
      end)

    Logger.info("#{__MODULE__} Run")

    POExtractor.extract_po_messages(dirs_data_access, extended_opts)
  end

  def list_all_po_dirs_from_kanta_backends do
    # Find all modules that implement the behavior
    for {module, _} <- :code.all_loaded(),
        module_implements_behavior?(module, Kanta.Backend) do
      module.__gettext__(:priv)
    end
  end

  defp get_priv_dir(backend_module) do
    if module_implements_behavior?(backend_module, Kanta.Backend) do
      backend_module.__gettext__(:priv)
    else
      Logger.error(
        "#{backend_module} is not a Kanta.Backend implementation. PO messages are not extracted."
      )

      nil
    end
  end

  defp module_implements_behavior?(module, behavior) when is_atom(module) do
    # Check if a module implements a behavior
    try do
      behaviors =
        module.__info__(:attributes)
        |> Keyword.get_values(:behaviour)
        |> List.flatten()

      behavior in behaviors
    rescue
      # Handle cases where module doesn't exist or is not an Elixir module
      _ -> false
    end
  end
end
