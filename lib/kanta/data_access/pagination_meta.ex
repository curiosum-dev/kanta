defmodule Kanta.DataAccess.PaginationMeta do
  @type t :: %__MODULE__{
          page: pos_integer(),
          page_size: pos_integer(),
          total_pages: non_neg_integer(),
          total_entries: non_neg_integer()
        }

  defstruct [:total_pages, :total_entries, :page, :page_size]
end
