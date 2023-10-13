defmodule Kanta.Config do
  @moduledoc """
  Kanta configuration helper
  """
  @type t :: %__MODULE__{
          name: atom(),
          otp_name: atom(),
          repo: module(),
          endpoint: module(),
          plugins: false | [module() | {module() | Keyword.t()}],
          disable_api_authorization: boolean()
        }

  defstruct name: Kanta,
            otp_name: nil,
            repo: nil,
            endpoint: nil,
            plugins: [],
            disable_api_authorization: false

  alias Kanta.Validator

  @doc """
  Generate a Config struct after normalizing and verifying Kanta options.

  See `Kanta.start_link/1` for a comprehensive description of available options.

  ## Example

  Generate a minimal config with only a `:repo`:

      Kanta.Config.new(repo: Kanta.Test.Repo)
  """
  def new(opts) when is_list(opts) do
    opts = normalize(opts)

    Validator.validate!(opts, &validate/1)

    struct!(__MODULE__, opts)
  end

  def validate(opts) when is_list(opts) do
    opts = normalize(opts)

    Validator.validate(opts, &validate_opt(opts, &1))
  end

  defp validate_opt(_opts, {:plugins, plugins}) do
    Validator.validate(:plugins, plugins, &validate_plugin/1)
  end

  defp validate_opt(_opts, {:repo, repo}) do
    if Code.ensure_loaded?(repo) and function_exported?(repo, :config, 0) do
      :ok
    else
      {:error, "expected :repo to be an Ecto.Repo, got: #{inspect(repo)}"}
    end
  end

  defp validate_opt(_opts, {:endpoint, endpoint}) do
    if Code.ensure_loaded?(endpoint) do
      :ok
    else
      {:error, "expected :endpoint to be loaded"}
    end
  end

  defp validate_opt(_opts, {:otp_name, otp_name}) do
    if is_atom(otp_name) do
      :ok
    else
      {:error, "expected otp_name to be set"}
    end
  end

  defp validate_opt(_opts, {:disable_api_authorization, disable_api_authorization}) do
    if is_boolean(disable_api_authorization) do
      :ok
    else
      {:error,
       "expected :disable_api_authorization to be a boolean, got: #{inspect(disable_api_authorization)}"}
    end
  end

  defp validate_opt(_opts, option) do
    {:unknown, option, __MODULE__}
  end

  defp validate_plugin(plugin) when not is_tuple(plugin), do: validate_plugin({plugin, []})

  defp validate_plugin({plugin, opts}) do
    name = inspect(plugin)

    cond do
      not is_atom(plugin) ->
        {:error, "plugin #{name} is not a valid module"}

      not Code.ensure_loaded?(plugin) ->
        {:error, "plugin #{name} could not be loaded"}

      not function_exported?(plugin, :init, 1) ->
        {:error, "plugin #{name} is invalid because it's missing an `init/1` function"}

      not Keyword.keyword?(opts) ->
        {:error, "expected #{name} options to be a keyword list, got: #{inspect(opts)}"}

      function_exported?(plugin, :validate, 1) ->
        plugin.validate(opts)

      true ->
        :ok
    end
  end

  # Normalization

  defp normalize(opts) do
    opts
    |> Keyword.update(:plugins, [], &normalize_plugins/1)
  end

  defp normalize_plugins(plugins) when is_list(plugins) do
    plugins
    |> Enum.map(&if is_atom(&1), do: {&1, []}, else: &1)
    |> Enum.reverse()
    |> Enum.uniq()
  end

  defp normalize_plugins(plugins), do: plugins || []
end
