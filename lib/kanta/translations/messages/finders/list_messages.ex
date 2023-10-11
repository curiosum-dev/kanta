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
    |> distinct(true)
    |> preload_resources(params[:preloads] || [])
    |> paginate(params[:page], params[:per_page])
  end

  defp not_translated_query(query, %{"locale_id" => locale_id, "not_translated" => "true"}) do
    query
    |> with_join(:singular_translations, locale_id: locale_id)
    |> where(
      [singular_translation: st],
      null_or_empty(st.translated_text) and null_or_empty(st.original_text)
    )
    |> with_join(:plural_translations, locale_id: locale_id)
    |> where(
      [plural_translation: pt],
      null_or_empty(pt.translated_text) and null_or_empty(pt.original_text)
    )
  end

  defp not_translated_query(query, _), do: query

  defp search_subquery(query, _, nil), do: query
  defp search_subquery(query, _, ""), do: query

  defp search_subquery(query, %{"locale_id" => locale_id}, search) do
    search_subquery(query, [locale_id: locale_id], search)
  end

  defp search_subquery(query, filter, _) when is_map(filter), do: query

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

  def join_resource(query, :singular_translations, opts) do
    locale_id = opts[:locale_id]

    join(query, :left, [message: m], st in assoc(m, :singular_translations),
      as: :singular_translation,
      on: st.message_id == m.id and st.locale_id == ^locale_id
    )
  end

  def join_resource(query, :plural_translations, opts) do
    locale_id = opts[:locale_id]

    join(query, :left, [message: m], pt in assoc(m, :plural_translations),
      as: :plural_translation,
      on: pt.message_id == m.id and pt.locale_id == ^locale_id
    )
  end
end
