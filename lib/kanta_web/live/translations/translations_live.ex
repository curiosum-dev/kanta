defmodule KantaWeb.Translations.TranslationsLive do
  use KantaWeb, :live_view

  alias KantaWeb.Translations.TranslationLiveComponent

  def render(assigns) do
    ~H"""
    <h1 class="my-3">
    Test
    </h1>
    """
  end

  def mount(_params, %{"language" => language}, socket) do
    # domains_with_translations =
    #   language
    #   |> Kanta.get_translations()
    #   |> sort_translations()
    #   |> group_translations_by_domains()

    {:ok, socket}
    #  |> assign(:language, language)
    #  |> assign(:domains_with_translations, domains_with_translations)}
  end

  defp group_translations_by_domains(translations) do
    translations
    |> Enum.group_by(&elem(&1, 1))
  end

  defp sort_translations(translations) do
    {empty_translations, filled_translations} =
      translations
      |> Enum.reduce({[], []}, fn translation, {empty, filled} ->
        case elem(translation, 4) === "" do
          true -> {[translation] ++ empty, filled}
          false -> {empty, [translation] ++ filled}
        end
      end)

    empty_translations ++ filled_translations
  end
end
