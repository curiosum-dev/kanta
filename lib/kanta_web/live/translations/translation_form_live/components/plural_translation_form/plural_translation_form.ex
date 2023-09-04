defmodule KantaWeb.Translations.PluralTranslationForm do
  @moduledoc """
  Plural translation form component
  """

  use KantaWeb, :live_component

  alias Kanta.Translations
  alias KantaWeb.Components.Shared.Tabs

  def update(assigns, socket) do
    tabs =
      Enum.map(
        assigns.translations,
        &%{
          index: &1.nplural_index + 1,
          label: "Form #{&1.nplural_index + 1}"
        }
      )

    translation =
      assigns.translations
      |> Enum.find(&(&1.nplural_index == assigns.current_tab_index))

    form =
      if is_nil(translation),
        do: nil,
        else: %{
          "id" => translation.id,
          "nplural_index" => translation.nplural_index,
          "original_text" => translation.original_text,
          "translated_text" => translation.translated_text
        }

    socket =
      socket
      |> assign(:tabs, tabs)
      |> assign(:translation, translation)
      |> assign(:form, form)

    {:ok, assign(socket, assigns)}
  end

  def handle_event("validate", attrs, socket) do
    [translated] = attrs |> Map.drop(["_target"]) |> Map.values()

    {:noreply, update(socket, :form, &Map.merge(&1, %{"translated_text" => translated}))}
  end

  def handle_event("submit", attrs, socket) do
    locale = socket.assigns.locale
    ["translated_text." <> nplural_index] = Map.keys(attrs)
    [translated] = Map.values(attrs)

    translation =
      Enum.find(
        socket.assigns.translations,
        &(&1.nplural_index == String.to_integer(nplural_index))
      )

    Translations.update_plural_translation(translation, %{
      "translated_text" => translated
    })

    {:noreply,
     push_redirect(socket,
       to:
         unverified_path(
           socket,
           Kanta.Router,
           "/kanta/locales/#{locale.id}/translations"
         )
     )}
  end

  def plural_examples(locale, index) do
    forms_struct = Expo.PluralForms.parse!(locale.plurals_header)

    Enum.group_by(0..30, &Expo.PluralForms.index(forms_struct, &1), & &1)
    |> Map.fetch!(index)
    |> Enum.join(", ")
  end
end
