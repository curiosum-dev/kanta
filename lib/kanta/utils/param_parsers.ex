defmodule Kanta.Utils.ParamParsers do
  @moduledoc false

  def parse_page(page) do
    case Integer.parse(page) do
      {page, _} -> page
      _ -> 1
    end
  end

  def parse_id_filter(id) do
    case Integer.parse(id) do
      {id, _} -> id
      _ -> nil
    end
  end
end
