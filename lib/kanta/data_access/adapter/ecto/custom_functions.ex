defmodule Kanta.DataAccess.Adapter.Ecto.CustomFunctions do
  @moduledoc """
  Custom SQL functions for use with Ecto.
  """

  defmacro sql_case(value, params) do
    build_case("CASE ? ", "END", value, params)
  end

  defmacro count_case(value, params) do
    build_case("COUNT(CASE ? ", "END)", value, params)
  end

  defp build_case(prefix, suffix, value, params) do
    {template, args} =
      Enum.reduce(params, {"", []}, fn
        [when: condition, then: result], {tpl, args} ->
          {"#{tpl}WHEN ? THEN ? ", args ++ [condition, result]}

        [else: result], {tpl, args} ->
          {"#{tpl}ELSE ? ", args ++ [result]}
      end)

    full_template = prefix <> template <> suffix
    all_args = [value | args]

    quote do
      fragment(unquote(full_template), unquote_splicing(all_args))
    end
  end
end
