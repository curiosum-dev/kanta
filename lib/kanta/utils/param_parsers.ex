defmodule Kanta.Utils.ParamParsers do
  @moduledoc false

  def default_id_parser(id) do
    case Integer.parse(id) do
      {id, _} -> {:ok, id}
      _ -> :error
    end
  end

  def parse_page(page) do
    case Integer.parse(page) do
      {page, _} -> page
      _ -> 1
    end
  end

  def parse_id_filter(id) do
    run_parse_function(Kanta.config().id_parse_function, id)
  end

  defp run_parse_function(parse_function, id) when is_function(parse_function, 1) do
    parse_function.(id)
  end

  defp run_parse_function({module, parse_function, 1}, id) do
    apply(module, parse_function, [id])
  end

  defp run_parse_function(_, _) do
    raise "Invalid id_parse_function provided in Kanta's config"
  end
end
