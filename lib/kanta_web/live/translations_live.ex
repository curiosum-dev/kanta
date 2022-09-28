defmodule KantaWeb.TranslationsLive do
  use KantaWeb, :live_view
  alias KantaWeb.TranslationLiveComponent

  def render(assigns) do
    ~H"""
    <h1 class="my-3">
      Language: <%= @language %>
    </h1>
    <div>
      <%= for {domain, translations} <- @domains_with_translations do %>
        <div class="mb-3">
          <h2 class="mb-2">Domain: <%= domain %></h2>
          <%= for translation <- translations do %>
            <.live_component
              module={TranslationLiveComponent}
              language={@language}
              domain={domain}
              msgctxt={elem(translation, 2)}
              msgid={elem(translation, 3)}
              translated={elem(translation, 4)}
              id={"#{elem(translation, 3)}#{elem(translation, 2)}"}
            />
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  def mount(_params, %{"language" => language}, socket) do
    domains_with_translations =
      language
      |> Kanta.get_translations()
      |> sort_translations()
      |> group_translations_by_domains()

    {:ok,
     socket
     |> assign(:language, language)
     |> assign(:domains_with_translations, domains_with_translations)}
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
