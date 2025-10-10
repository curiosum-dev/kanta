defmodule Mix.Tasks.Kanta.PruneStale do
  @moduledoc """
  Deletes stale messages and their translations from the database.

  Stale messages are messages that don't exist in ANY locale's PO files.
  This task permanently deletes the messages and ALL their translations across ALL locales.

  ## Usage

      mix kanta.prune_stale [OPTIONS]

  ## Options

    * `--dry-run` - Preview which messages would be deleted without actually deleting them
    * `--force` - Skip confirmation prompt and delete immediately

  ## Examples

      # Preview stale messages without deleting
      mix kanta.prune_stale --dry-run

      # Delete with confirmation prompt
      mix kanta.prune_stale

      # Delete without confirmation
      mix kanta.prune_stale --force

  ## Example Output

      Detecting stale messages (system-wide)...
      Found 3 stale messages

      Continue with deletion? [y/N] y

      Deleting stale messages...
      ✓ Deleted 3 messages and 12 translations

  """

  use Mix.Task

  @shortdoc "Deletes stale messages from database"

  @switches [dry_run: :boolean, force: :boolean]
  @aliases [d: :dry_run, f: :force]

  @impl true
  def run(args) do
    Mix.Task.run("app.start")

    {opts, _} = OptionParser.parse!(args, strict: @switches, aliases: @aliases)

    Mix.shell().info("Detecting stale messages (system-wide)...")

    {:ok, result} = Kanta.POFiles.Services.IdentifyStaleTranslations.call()

    stale_count = result.stats.stale_count

    if stale_count == 0 do
      Mix.shell().info("✓ No stale messages found.")
    else
      Mix.shell().info("Found #{stale_count} stale #{pluralize("message", stale_count)}")
      handle_stale_messages(result.stale_message_ids, opts)
    end
  end

  defp handle_stale_messages(stale_ids, opts) do
    count = MapSet.size(stale_ids)

    if opts[:dry_run] do
      run_dry_run(count)
    else
      run_deletion(stale_ids, count, opts[:force])
    end
  end

  defp run_dry_run(count) do
    Mix.shell().info("")

    Mix.shell().info(
      "⚠ [DRY RUN] Would delete #{count} stale #{pluralize("message", count)} and ALL their translations"
    )

    Mix.shell().info("")
    Mix.shell().info("Run without --dry-run to perform actual deletion.")
  end

  defp run_deletion(stale_ids, count, force?) do
    Mix.shell().info("")

    Mix.shell().info(
      "⚠ This will delete #{count} #{pluralize("message", count)} and ALL their translations across ALL locales."
    )

    Mix.shell().info("")

    if force? || confirm_deletion() do
      Mix.shell().info("Deleting stale messages...")
      Mix.shell().info("")

      {total_messages, total_translations} =
        stale_ids
        |> MapSet.to_list()
        |> Enum.reduce({0, 0}, fn message_id, {msg_count, trans_count} ->
          case Kanta.Translations.delete_stale_message(message_id) do
            {:ok, stats} ->
              {
                msg_count + if(stats.message_deleted, do: 1, else: 0),
                trans_count + stats.translations_deleted
              }

            {:error, reason} ->
              Mix.shell().error("✗ Failed to delete message #{message_id}: #{inspect(reason)}")
              {msg_count, trans_count}
          end
        end)

      Mix.shell().info(
        "✓ Deleted #{total_messages} #{pluralize("message", total_messages)} and #{total_translations} #{pluralize("translation", total_translations)}"
      )
    else
      Mix.shell().info("Deletion cancelled.")
    end
  end

  defp confirm_deletion do
    case Mix.shell().prompt("Continue with deletion? [y/N]") do
      answer when answer in ["y", "Y", "yes", "Yes", "YES"] -> true
      _ -> false
    end
  end

  defp pluralize(word, 1), do: word
  defp pluralize(word, _), do: "#{word}s"
end
