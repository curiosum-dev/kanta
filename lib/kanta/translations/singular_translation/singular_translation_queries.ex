defmodule Kanta.Translations.SingularTranslationQueries do
  use Kanta.Query,
    module: Kanta.Translations.SingularTranslation,
    binding: :singular_translation

  def join_resource(query, :locale) do
    join(query, :inner, [singular_translation: st], _ in assoc(st, :locale), as: :locale)
  end

  def join_resource(query, :domain) do
    join(query, :inner, [singular_translation: st], _ in assoc(st, :domain), as: :domain)
  end

  def filter_by_locale(query, locale) do
    query
    |> with_join(:locale)
    |> where(
      [locale: lo],
      lo.name == ^locale
    )
  end

  def filter_by_domain(query, domain) do
    query
    |> with_join(:domain)
    |> where(
      [domain: dm],
      dm.name == ^domain
    )
  end
end
