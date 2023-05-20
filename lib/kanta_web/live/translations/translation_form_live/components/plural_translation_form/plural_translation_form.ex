defmodule KantaWeb.Translations.PluralTranslationForm do
  @moduledoc """
  Plural translation form component
  """

  use KantaWeb, :live_component

  alias Kanta.Translations
  alias Kanta.Plugins.DeepL.Adapter

  def update(assigns, socket) do
    forms =
      assigns.translations
      |> Enum.map(fn translation ->
        %{
          "id" => translation.id,
          "nplural_index" => translation.nplural_index,
          "original_text" => translation.original_text,
          "translated_text" => translation.translated_text
        }
      end)

    socket =
      socket
      |> assign(:forms, forms)

    {:ok, assign(socket, assigns)}
  end

  def handle_event("overwrite_po", %{"nplural_index" => nplural_index}, socket) do
    %{forms: forms, locale: locale, message: message} = socket.assigns

    nplural_index = String.to_integer(nplural_index)

    form =
      Enum.find(forms, fn form ->
        form["nplural_index"] == nplural_index
      end)

    Kanta.Plugins.POWriter.OverwritePoMessage.plural(
      form["translated_text"],
      nplural_index,
      locale,
      message
    )

    Translations.update_plural_translation(form["id"], %{
      "original_text" => form["translated_text"]
    })

    {:noreply, socket}
  end

  def handle_event("translate_via_deep_l", %{"nplural_index" => nplural_index}, socket) do
    %{forms: forms, locale: locale, message: message} = socket.assigns

    form =
      Enum.find(forms, fn form ->
        form["nplural_index"] == String.to_integer(nplural_index)
      end)

    case Adapter.request_translation(
           "EN",
           String.upcase(locale.iso639_code),
           message.msgid
         ) do
      {:ok, translations} ->
        %{"text" => translated_text} = List.first(translations)

        form = Map.put(form, "translated_text", translated_text)

        {:noreply,
         update(
           socket,
           :forms,
           &(&1
             |> Enum.reject(fn f ->
               Map.get(f, "nplural_index") == Map.get(form, "nplural_index")
             end)
             |> Enum.concat([form]))
         )}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event(
        "validate",
        %{"_target" => [target]} = attrs,
        socket
      ) do
    %{forms: forms} = socket.assigns

    "translated_text." <> nplural_index = target
    translation = Map.get(attrs, target)

    form =
      Enum.find(forms, fn form ->
        form["nplural_index"] == String.to_integer(nplural_index)
      end)

    form = Map.put(form, "translated_text", translation)

    forms =
      forms
      |> Enum.reject(&(&1["id"] == form["id"]))
      |> Enum.concat([form])

    {:noreply, assign(socket, :forms, forms)}
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
end
