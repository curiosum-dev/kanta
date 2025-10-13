defmodule KantaWeb.Translations.Components.MessagesTable do
  @moduledoc """
  Gettext messages table component
  """

  use KantaWeb, :live_component

  alias Kanta.Translations.{Message, SingularTranslation}

  @available_params ~w(page search filter)
  @params_in_filter ~w(domain_id context_id not_translated stale)

  def update(socket, assigns) do
    {:ok, assign(assigns, socket)}
  end

  def message_stale?(message, stale_message_ids) do
    MapSet.member?(stale_message_ids, message.id)
  end

  def handle_event("edit_message", %{"id" => id}, socket) do
    params = get_filter_params_from_assigns(socket.assigns)
    query = UriQuery.params(params)

    {:noreply,
     push_navigate(socket,
       to:
         dashboard_path(
           socket,
           "/locales/#{socket.assigns.locale.id}/translations/#{id}?" <>
             URI.encode_query(query)
         )
     )}
  end

  def handle_event("delete_stale", %{"message-id" => message_id}, socket) do
    require Logger
    message_id = String.to_integer(message_id)

    case Kanta.Translations.delete_message(message_id) do
      {:ok, stats} ->
        Logger.debug("Deleted message and translations: #{inspect(stats)}")
        Logger.debug("Sending refresh_messages to parent PID: #{inspect(self())}")
        send(self(), :refresh_messages)
        {:noreply, socket}

      {:error, reason} ->
        Logger.error("Failed to delete: #{inspect(reason)}")
        {:noreply, socket}
    end
  end

  def handle_event(
        "merge_messages",
        %{"from-id" => from_id, "to-id" => to_id},
        socket
      ) do
    require Logger
    from_message_id = String.to_integer(from_id)
    to_message_id = String.to_integer(to_id)

    case Kanta.Translations.merge_messages(from_message_id, to_message_id) do
      {:ok, target_message} ->
        Logger.debug(
          "Merged message #{from_message_id} into #{to_message_id}: #{inspect(target_message)}"
        )

        Logger.debug("Sending refresh_messages to parent PID: #{inspect(self())}")
        notify_parent_refresh()
        {:noreply, socket}

      {:error, reason} ->
        Logger.error("Failed to merge messages: #{inspect(reason)}")
        {:noreply, socket}
    end
  end

  def translated?(%Message{message_type: :singular} = message, locale, source) do
    case Enum.find(message.singular_translations, &(&1.locale_id == locale.id)) do
      nil ->
        false

      %SingularTranslation{} = translation ->
        case get_in(translation, [Access.key!(source)]) do
          nil -> false
          "" -> false
          _text -> true
        end
    end
  end

  def translated?(%Message{message_type: :plural} = message, locale, source) do
    case Enum.filter(message.plural_translations, &(&1.locale_id == locale.id)) do
      [] ->
        false

      translations ->
        translations
        |> Enum.map(&plural_form_translated?(&1, source))
    end
  end

  defp plural_form_translated?(translation, source) do
    case get_in(translation, [Access.key!(source)]) do
      nil ->
        false

      "" ->
        false

      _text ->
        true
    end
  end

  def translated_text(assigns, %Message{message_type: :singular} = message),
    do: translated_singular_text(assigns, message, :translated_text)

  def translated_text(assigns, %Message{message_type: :plural} = message),
    do: translated_plural_text(assigns, message, :translated_text)

  def original_text(assigns, %Message{message_type: :singular} = message),
    do: translated_singular_text(assigns, message, :original_text)

  def original_text(assigns, %Message{message_type: :plural} = message),
    do: translated_plural_text(assigns, message, :original_text)

  def translated_singular_text(assigns, message, source) do
    case Enum.find(message.singular_translations, &(&1.locale_id == assigns.locale.id)) do
      nil ->
        "Missing"

      %SingularTranslation{} = translation ->
        case get_in(translation, [Access.key!(source)]) do
          nil -> "Missing"
          "" -> "Missing"
          text -> truncate_translation(text)
        end
    end
  end

  def translated_plural_text(assigns, message, source) do
    translations =
      case Enum.filter(message.plural_translations, &(&1.locale_id == assigns.locale.id)) do
        [] ->
          []

        translations ->
          translations
          |> Enum.map(fn translation ->
            text = get_plural_form_text(translation, source)

            %{index: translation.nplural_index, text: text}
          end)
      end

    assigns = assign(assigns, :translations, translations)

    if length(translations) > 0 do
      ~H"""
        <div>
          <%= for plural_translation <- Enum.sort_by(@translations, & &1[:index], :asc) do %>
            <div class={"#{if plural_translation[:text] != "Missing", do: "text-green-700 dark:text-green-500", else: "text-red-700 dark:text-red-500"}"}>
              Plural form <%= plural_translation[:index] %>: <%= plural_translation[:text] %>
            </div>
          <% end %>
        </div>
      """
    else
      "Missing"
    end
  end

  defp get_plural_form_text(translation, source) do
    case get_in(translation, [Access.key!(source)]) do
      nil ->
        "Missing"

      "" ->
        "Missing"

      text ->
        truncate_translation(text)
    end
  end

  defp truncate_translation(text) do
    if String.length(text) > 45, do: String.slice(text, 0..45) <> "... ", else: text
  end

  defp get_filter_params_from_assigns(%{filters: filters}) do
    filter =
      filters
      |> Map.take(@params_in_filter)
      |> Map.reject(fn {_, value} -> is_nil(value) or value == "" end)

    params =
      filters
      |> Map.take(@available_params)
      |> Map.put("filter", filter)
      |> Map.reject(fn {_, value} -> is_nil(value) or value == "" end)

    %{"filters" => params}
  end

  defp notify_parent_refresh do
    send(self(), :refresh_messages)
  end
end
