defmodule KantaWeb.Dashboard.DashboardLive do
  alias Kanta.LocaleInfo
  use KantaWeb, :live_view

  alias Kanta.Cache
  # alias Kanta.Translations
  alias Kanta.Translations.Locale.Finders.GetLocaleTranslationProgress

  def mount(_params, session, socket) do
    data_access = session["data_access"]
    # TODO Cache cleaning
    cache = session["cache"]

    domain_count = data_access.count_resource(:domain)
    context_count = data_access.count_resource(:context)
    # locales_count = data_access.count_resource(:locale)
    singular_count = data_access.count_resource(:singular)
    plural_count = data_access.count_resource(:plural)
    all_messages_count = singular_count + plural_count

    cache_count = maybe_get_cache_count(cache)
    locales = data_access.locales() |> get_locales_information()
    locales_tranlsation_progress = data_access.locales_translation_progress(locales)

    socket =
      socket
      |> assign(
        domain_count: domain_count,
        context_count: context_count,
        messages_count: all_messages_count,
        cache_count: cache_count,
        locales: locales,
        locales_translation_progress: locales_tranlsation_progress
      )

    {:ok, socket}
  end

  def handle_event("clear-cache", _, socket) do
    Cache.delete_all()

    {:noreply, assign(socket, :cache_count, Cache.count_all())}
  end

  def translation_progress(language) do
    GetLocaleTranslationProgress.find(language.id)
  end

  defp get_locales_information(locales) when is_list(locales) do
    locales
    |> Enum.map(fn locale ->
      locale_info =
        locale
        |> LocaleInfo.get_locale_info()

      {locale, locale_info}
    end)
  end

  defp show_locale_label({locale, nil}), do: locale

  defp show_locale_label({_locale, %LocaleInfo{} = locale_info}),
    do: "#{locale_info.language_name} #{locale_info.unicode_flag}"

  defp show_translation_progress(locales_translaption_progress_map, locale_str) do
    Map.get(locales_translaption_progress_map, locale_str, Decimal.new("0"))
    |> Decimal.mult(100)
    |> Decimal.round(0, :floor)
    |> Decimal.to_string()
  end

  defp maybe_get_cache_count(nil), do: 0
  defp maybe_get_cache_count(cache), do: cache.count_all()
end
