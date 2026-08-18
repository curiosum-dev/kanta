defmodule KantaWeb.Dashboard.DashboardLive do
  use KantaWeb, :live_view

  alias Kanta.Cache
  alias Kanta.PoFiles.MessagesExtractorAgent
  alias Kanta.PoFiles.Services.StaleDetection.Result
  alias Kanta.Translations
  alias Kanta.Translations.Locale.Finders.GetLocaleTranslationProgress

  def mount(_params, _session, socket) do
    messages_count = Translations.get_messages_count()
    stale_messages_count = get_stale_messages_count()
    mergeable_messages_count = get_mergeable_messages_count()
    %{entries: domains, metadata: _domains_metadata} = Translations.list_domains()
    %{entries: contexts, metadata: _contexts_metadata} = Translations.list_contexts()
    %{entries: locales, metadata: _locales_metadata} = Translations.list_locales()

    socket =
      socket
      |> assign(:messages_count, messages_count)
      |> assign(:stale_messages_count, stale_messages_count)
      |> assign(:mergeable_messages_count, mergeable_messages_count)
      |> assign(:languages, locales)
      |> assign(:contexts, contexts)
      |> assign(:domains, domains)
      |> assign(:cache_count, Cache.count_all())

    {:ok, socket}
  end

  def handle_event("clear-cache", _, socket) do
    Cache.delete_all()

    {:noreply, assign(socket, :cache_count, Cache.count_all())}
  end

  def handle_event("delete-stale", _, socket) do
    if Kanta.config().disable_stale_detection do
      {:noreply, socket}
    else
      %Result{stale_message_ids: stale_message_ids} =
        MessagesExtractorAgent.get_stale_detection_result()

      Translations.delete_messages(MapSet.to_list(stale_message_ids))

      stale_messages_count =
        MessagesExtractorAgent.get_stale_detection_result(true).stale_count

      {:noreply, assign(socket, :stale_messages_count, stale_messages_count)}
    end
  end

  # Merge all the orphaned messages to selected target messages (that fuzzy mathed).
  def handle_event("restore-mergeable", _, socket) do
    if Kanta.config().disable_stale_detection do
      {:noreply, socket}
    else
      %Result{fuzzy_matches_map: fuzzy_matches_map} =
        MessagesExtractorAgent.get_stale_detection_result()

      # Merge all messages with fuzzy matches
      Enum.each(fuzzy_matches_map, fn {_stale_id, fuzzy_match} ->
        Translations.merge_messages(fuzzy_match.stale_message_id, fuzzy_match.matched_message_id)
      end)

      result = MessagesExtractorAgent.get_stale_detection_result(true)

      {:noreply,
       socket
       |> assign(:mergeable_messages_count, result.mergeable_count)
       |> assign(:stale_messages_count, result.stale_count)}
    end
  end

  def translation_progress(language) do
    GetLocaleTranslationProgress.find(language.id)
  end

  defp get_stale_messages_count do
    if Kanta.config().disable_stale_detection do
      0
    else
      case MessagesExtractorAgent.get_stale_detection_result() do
        nil -> 0
        %Result{stale_count: stale_count} -> stale_count
      end
    end
  end

  defp get_mergeable_messages_count do
    if Kanta.config().disable_stale_detection do
      0
    else
      case MessagesExtractorAgent.get_stale_detection_result() do
        nil -> 0
        %Result{mergeable_count: mergeable_count} -> mergeable_count
      end
    end
  end
end
