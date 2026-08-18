defmodule KantaWeb.Translations.LocalesLive do
  use KantaWeb, :live_view

  alias Kanta.Translations
  alias Kanta.Utils.Colors

  def mount(_params, _session, socket) do
    %{entries: locales, metadata: _entries_metadata} = Translations.list_locales()

    {:ok,
     socket
     |> assign(:locales, locales)}
  end

  def generate_locale_gradient(locale) do
    colors = locale.colors || []

    case length(colors) do
      0 ->
        "background: #{Colors.default_color()};"

      1 ->
        "background: #{List.first(colors)};"

      2 ->
        "background: #{List.first(colors)}; background: linear-gradient(145deg, #{Enum.at(colors, 0)} 45%, #{Enum.at(colors, 1)} 50% 100%);"

      _ ->
        "background: #{List.first(colors)}; background: linear-gradient(145deg, #{Enum.at(colors, 0)} 0% 30%, #{Enum.at(colors, 1)} 33% 66%, #{Enum.at(colors, 2)} 66% 100%);"
    end
  end
end
