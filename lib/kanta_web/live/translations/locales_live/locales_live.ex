defmodule KantaWeb.Translations.LocalesLive do
  use KantaWeb, :live_view

  alias Kanta.Translations

  def mount(_params, _session, socket) do
    locales = Translations.list_locales()

    {:ok,
     socket
     |> assign(:locales, locales)}
  end

  def generate_locale_gradient(locale) do
    case length(locale.colors) do
      1 ->
        "background: #{List.first(locale.colors)};"

      2 ->
        "background: #{List.first(locale.colors)}; background: linear-gradient(145deg, #{Enum.at(locale.colors, 0)} 50%, #{Enum.at(locale.colors, 1)} 50% 100%);"

      3 ->
        "background: #{List.first(locale.colors)}; background: linear-gradient(145deg, #{Enum.at(locale.colors, 0)} 0% 33%, #{Enum.at(locale.colors, 1)} 33% 66%, #{Enum.at(locale.colors, 2)} 66% 100%);"
    end
  end
end
