defmodule Kanta.Translations.Messages.Finders.ListMessages do
  @moduledoc """
  Query module aka Finder responsible for listing gettext messages
  """

  use Kanta.Query,
    module: Kanta.Translations.Message,
    binding: :message

  alias Kanta.Translations.PluralTranslations.Finders.ListPluralTranslations
  alias Kanta.Translations.SingularTranslations.Finders.ListSingularTranslations

  @available_filters ~w(domain_id context_id)

  def find(params \\ []) do
    base()
    |> filter_query(Map.take(params[:filter] || %{}, @available_filters))
    |> not_translated_query(params[:filter])
    |> search_subquery(params[:filter], params[:search])
    |> preload_resources(params[:preloads] || [])
    |> paginate(String.to_integer(params[:page] || "1"), params[:per_page])
  end

  defp not_translated_query(query, %{"locale_id" => locale_id, "not_translated" => "true"}) do
    singular_messages_query =
      query
      |> with_join(:singular_translations, %{"locale_id" => locale_id})
      |> where(
        [singular_translation: st],
        (is_nil(st.translated_text) or
           st.translated_text == "") and
          (is_nil(st.original_text) or
             st.original_text == "")
      )

    plural_messages_query =
      query
      |> with_join(:plural_translations, %{"locale_id" => locale_id})
      |> where(
        [plural_translation: pt],
        (is_nil(pt.translated_text) or
           pt.translated_text == "") and
          (is_nil(pt.original_text) or
             pt.original_text == "")
      )

    union_query = union_all(singular_messages_query, ^plural_messages_query)

    from(_ in subquery(union_query), as: :message)
  end

  defp not_translated_query(query, _), do: query

  defp search_subquery(query, _, nil), do: query
  defp search_subquery(query, _, ""), do: query

  defp search_subquery(query, filter, search) do
    sub =
      base()
      |> search_query(search)
      |> with_join(:singular_translations, filter)
      |> with_join(:plural_translations, filter)
      |> ListPluralTranslations.search_query(search)
      |> ListSingularTranslations.search_query(search)
      |> subquery()

    join(query, :inner, [message: m], sq in ^sub, on: sq.id == m.id)
  end

  def join_resource(query, :singular_translations, %{"locale_id" => locale_id}) do
    join(query, :left, [message: m], st in assoc(m, :singular_translations),
      as: :singular_translation,
      on: st.message_id == m.id and st.locale_id == ^locale_id
    )
  end

  def join_resource(query, :plural_translations, %{"locale_id" => locale_id}) do
    join(query, :left, [message: m], pt in assoc(m, :plural_translations),
      as: :plural_translation,
      on: pt.message_id == m.id and pt.locale_id == ^locale_id
    )
  end
end
