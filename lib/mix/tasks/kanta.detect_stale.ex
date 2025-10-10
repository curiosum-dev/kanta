defmodule Mix.Tasks.Kanta.DetectStale do
  @moduledoc """
  Detects stale translations and updates the cache.

  Stale translations are messages that exist in the database but are no longer
  present in PO files. This task:

  1. Scans all PO files in the configured gettext directory
  2. Compares with messages stored in the database
  3. Identifies messages that are in DB but not in PO files
  4. Updates the cache with stale message IDs
  5. Prints statistics

  ## Usage

      mix kanta.detect_stale

  ## Example Output

      Detecting stale translations...
      ✓ Scanned PO files: 45 active messages found
      ✓ Database messages: 50 total
      ⚠ Stale translations: 5 messages

      Stale message IDs cached successfully.

  """

  use Mix.Task

  @shortdoc "Detects and caches stale translation messages"

  @impl true
  def run(_args) do
    Mix.Task.run("app.start")

    Mix.shell().info("Detecting stale translations (system-wide)...")

    {:ok, result} = Kanta.POFiles.Services.IdentifyStaleTranslations.call()

    stats = result.stats

    Mix.shell().info(
      "✓ Scanned PO files across all locales: #{stats.active_count} active messages found"
    )

    Mix.shell().info("✓ Database messages: #{stats.total_db_messages} total")

    if stats.stale_count > 0 do
      Mix.shell().info(
        "⚠ Stale messages: #{stats.stale_count} (not found in ANY locale's PO files)"
      )

      Mix.shell().info("\nRun 'mix kanta.prune_stale' to delete them.")
    else
      Mix.shell().info("✓ No stale messages found")
    end
  end
end
