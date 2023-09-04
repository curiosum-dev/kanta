defmodule Kanta.Translations.Messages.Finders.ListMessages do
  @moduledoc """
  Query module aka Finder responsible for listing gettext messages
  """

  use Kanta.Query,
    module: Kanta.Translations.Message,
    binding: :message

  alias Kanta.Translations.{PluralTranslation, SingularTranslation}

  @available_filters ~w(domain_id context_id)

  def find(params \\ []) do
    base()
    |> not_translated_query(params[:filter])
    |> filter_query(Map.take(params[:filter] || %{}, @available_filters))
    |> search_query(params[:search])
    |> preload_resources(params[:preloads] || [])
    |> paginate(String.to_integer(params[:page] || "1"), params[:per_page])
  end

  defp not_translated_query(query, %{"locale_id" => locale_id, "not_translated" => "true"}) do
    singular_messages_query =
      from(m in query,
        join: st in SingularTranslation,
        on: st.message_id == m.id,
        where: st.locale_id == ^locale_id,
        where:
          (is_nil(st.translated_text) or st.translated_text == "") and
            (is_nil(st.original_text) or st.original_text == "")
      )

    plural_messages_query =
      from(m in query,
        join: pt in PluralTranslation,
        on: pt.message_id == m.id,
        where: pt.locale_id == ^locale_id,
        where:
          (is_nil(pt.translated_text) or pt.translated_text == "") and
            (is_nil(pt.original_text) or pt.original_text == "")
      )

    union_query = union_all(singular_messages_query, ^plural_messages_query)

    from(m in subquery(union_query))
  end

  defp not_translated_query(query, _), do: query
end
