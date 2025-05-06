defmodule KantaWeb.Translations.LocalesLive do
  alias Kanta.LocaleInfo
  use KantaWeb, :live_view

  def mount(_params, session, socket) do
    # %{entries: locales, metadata: _entries_metadata} = Translations.list_locales()
    data_access = session["data_access"]
    data_access_locales = data_access.locales()

    locales =
      data_access_locales |> Enum.map(&LocaleInfo.get_locale_info/1)

    {:ok,
     socket
     |> assign(:locales, locales)}
  end

  def generate_locale_gradient(%LocaleInfo{flag_colors: flag_colors}) when is_list(flag_colors) do
    case length(flag_colors) do
      1 ->
        "background: #{List.first(flag_colors)};"

      2 ->
        "background: #{List.first(flag_colors)}; background: linear-gradient(145deg, #{Enum.at(flag_colors, 0)} 45%, #{Enum.at(flag_colors, 1)} 50% 100%);"

      3 ->
        "background: #{List.first(flag_colors)}; background: linear-gradient(145deg, #{Enum.at(flag_colors, 0)} 0% 30%, #{Enum.at(flag_colors, 1)} 33% 66%, #{Enum.at(flag_colors, 2)} 66% 100%);"
    end
  end

  def generate_locale_gradient(_), do: "#000000"
end
