defmodule Kanta.Validator do
  def validate(parent_key \\ nil, opts, validator)

  def validate(_parent_key, opts, validator) when is_list(opts) and is_function(validator, 1) do
    Enum.reduce_while(opts, :ok, fn opt, acc ->
      case validator.(opt) do
        :ok -> {:cont, acc}
        {:error, _reason} = error -> {:halt, error}
        {:unknown, field, module} -> {:halt, unknown_error(field, module)}
      end
    end)
  end

  def validate(parent_key, opts, _validator) do
    {:error, "expected #{inspect(parent_key)} to be a list, got: #{inspect(opts)}"}
  end

  def validate!(opts, validator) do
    with {:error, reason} <- validator.(opts), do: raise(ArgumentError, reason)
  end

  defp unknown_error({name, _value}, known), do: unknown_error(name, known)

  defp unknown_error(name, module) when is_atom(module) do
    name = to_string(name)

    module
    |> struct([])
    |> Map.from_struct()
    |> Enum.map(fn {known, _} -> {String.jaro_distance(name, to_string(known)), known} end)
    |> Enum.sort(:desc)
    |> case do
      [{score, known} | _] when score > 0.7 ->
        {:error, "unknown option :#{name}, did you mean :#{known}?"}

      _ ->
        {:error, "unknown option :#{name}"}
    end
  end
end
