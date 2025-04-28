defmodule Kanta.Migrations.Common.V1Denormalized do
  @moduledoc """
  Kanta Common V5 Migration: Defines the simple, denormalized schema
  and handles data migration from previous versions using INSERT INTO...SELECT.

  Renames domain/context tables to 'kanta_domain_metadata', 'kanta_context_metadata'.
  Uses empty string "" as sentinel for optional unique keys (domain, msgctxt).
  """
  use Ecto.Migration

  # Define standardized V5 table names
  @plural_table "kanta_plurals"
  @singular_table "kanta_singulars"
  # Renamed
  @domain_meta_table "kanta_domain_metadata"
  # Renamed
  @context_meta_table "kanta_context_metadata"
  @kant_messages "kanta_messages"

  # Tables from the previous schema (V1-V4 PG / V1-V3 SQLite) that need cleanup
  @old_tables [
    "kanta_plural_translations",
    "kanta_singular_translations",
    "kanta_messages",

    # Existed in PG V3 / SQLite V2
    "kanta_application_sources",
    # Old table name
    "kanta_contexts",
    # Old table name
    "kanta_domains",
    "kanta_locales"
  ]

  # Helper to get prefix from opts
  defp prefix(opts), do: Map.get(opts, :prefix)

  def up(opts) do
    IO.puts("Running Kanta Common Migration V05 (up)...")

    prefix = prefix(opts)

    # --- Create the new simplified tables FIRST ---
    IO.puts(
      "Creating new Kanta V05 schema tables (#{@domain_meta_table}, #{@context_meta_table}, etc)..."
    )

    create_domain_metadata_table(opts)
    create_context_metadata_table(opts)
    create_plurals_table(opts)
    create_singulars_table(opts)
    IO.puts("Kanta V05 schema tables created.")
    flush()

    # --- Migrate Data using SQL ---
    IO.puts("Starting data migration from old schema (if exists) to V05 schema using SQL...")
    # Updated function name
    migrate_data_via_sql(prefix)
    IO.puts("Data migration complete.")
    flush()

    # --- Cleanup previous schema AFTER data migration ---
    IO.puts("Dropping potentially existing older Kanta tables...")

    Enum.each(@old_tables, fn table_name ->
      drop_if_exists(table(table_name, prefix: prefix(opts)))
    end)

    flush()

    IO.puts("Recreating kanta_messages for versioning (Postgres)")
    create_kanta_messages(opts)
    IO.puts("Older table cleanup complete.")
  end

  def down(opts) do
    IO.puts("Running Kanta Common Migration V05 (down)...")
    prefix = prefix(opts)

    # Drop the V5 tables
    IO.puts("Dropping Kanta V05 schema tables...")
    drop_if_exists table(@singular_table, prefix: prefix)
    drop_if_exists table(@plural_table, prefix: prefix)
    drop_if_exists table(@context_meta_table, prefix: prefix)
    drop_if_exists table(@domain_meta_table, prefix: prefix)
    IO.puts("Kanta V05 schema tables dropped.")
    IO.puts("Note: Reverting to pre-V05 schema requires separate steps/migrations.")
  end

  defp create_kanta_messages(opts) do
    prefix = prefix(opts)

    create table(@kant_messages, prefix: prefix) do
    end
  end

  # Uses @domain_meta_table
  defp create_domain_metadata_table(opts) do
    prefix = prefix(opts)

    create_if_not_exists table(@domain_meta_table, prefix: prefix) do
      add :name, :string, null: false
      add :description, :text, null: true
      add :color, :string, null: true
      timestamps()
    end

    create_if_not_exists unique_index(
                           @domain_meta_table,
                           [:name],
                           name: :kanta_domain_metadata_name_index,
                           prefix: prefix
                         )
  end

  # Uses @context_meta_table
  defp create_context_metadata_table(opts) do
    prefix = prefix(opts)

    create_if_not_exists table(@context_meta_table, prefix: prefix) do
      add :name, :string, null: false
      add :description, :text, null: true
      add :color, :string, null: true
      timestamps()
    end

    create_if_not_exists unique_index(
                           @context_meta_table,
                           [:name],
                           name: :kanta_context_metadata_name_index,
                           prefix: prefix
                         )
  end

  # Uses @plural_table
  defp create_plurals_table(opts) do
    prefix = prefix(opts)

    create_if_not_exists table(@plural_table, prefix: prefix) do
      add :locale, :string, null: false
      add :domain, :string, null: false, default: "default"
      add :msgctxt, :string, null: false, default: ""
      add :msgid, :text, null: false
      add :msgid_plural, :text, null: false
      add :msgstr, :text, null: true
      add :plural_index, :integer, null: false
      add :msgstr_origin, :string, null: true
      timestamps()
    end

    create_if_not_exists unique_index(
                           @plural_table,
                           [:locale, :domain, :msgctxt, :msgid, :msgid_plural, :plural_index],
                           name: :kanta_plurals_unique_index,
                           prefix: prefix
                         )
  end

  # Uses @singular_table
  defp create_singulars_table(opts) do
    prefix = prefix(opts)

    create_if_not_exists table(@singular_table, prefix: prefix) do
      add :locale, :string, null: false
      add :domain, :string, null: false, default: "default"
      add :msgctxt, :string, null: false, default: ""
      add :msgid, :text, null: false
      add :msgstr, :text, null: true
      add :msgstr_origin, :string, null: true
      timestamps()
    end

    create_if_not_exists unique_index(
                           @singular_table,
                           [:locale, :domain, :msgctxt, :msgid],
                           name: :kanta_singulars_unique_index,
                           prefix: prefix
                         )
  end

  # --- Data Migration Logic (Simplified with INSERT INTO...SELECT) ---
  defp migrate_data_via_sql(prefix) do
    old_messages_table_ref = table_ref("kanta_messages", prefix)

    # Check if old schema likely exists by checking for kanta_messages
    case repo().query("SELECT 1 FROM #{old_messages_table_ref} LIMIT 1", [], log: false) do
      {:ok, _} ->
        IO.puts(
          "Old 'kanta_messages' table found. Migrating data using SQL INSERT INTO...SELECT..."
        )

        migrate_domains_sql(prefix)
        migrate_contexts_sql(prefix)
        migrate_singulars_sql(prefix)
        migrate_plurals_sql(prefix)

      {:error, _} ->
        IO.puts("Old 'kanta_messages' table not found. Skipping SQL data migration.")
    end
  end

  # Uses INSERT INTO...SELECT for domains
  defp migrate_domains_sql(prefix) do
    old_table_ref = table_ref("kanta_domains", prefix)
    new_table_ref = table_ref(@domain_meta_table, prefix)

    sql = """
    INSERT INTO #{new_table_ref} (name, description, color, inserted_at, updated_at)
    SELECT name, description, color, inserted_at, updated_at
    FROM #{old_table_ref}
    -- Use database-specific ON CONFLICT clauses if needed and available
    -- PostgreSQL: ON CONFLICT (name) DO NOTHING
    -- SQLite: ON CONFLICT (name) DO NOTHING
    -- MySQL: INSERT IGNORE INTO ... SELECT ...
    -- Generic approach: Check existence if needed, or let unique index handle errors
    -- Assuming ON CONFLICT DO NOTHING is supported or index prevents duplicates:
    ON CONFLICT (name) DO NOTHING
    """

    run_migration_sql(sql, "domains metadata", ignore_if_old_missing: true)
  end

  # Uses INSERT INTO...SELECT for contexts
  defp migrate_contexts_sql(prefix) do
    old_table_ref = table_ref("kanta_contexts", prefix)
    new_table_ref = table_ref(@context_meta_table, prefix)

    sql = """
    INSERT INTO #{new_table_ref} (name, description, color, inserted_at, updated_at)
    SELECT name, description, color, inserted_at, updated_at
    FROM #{old_table_ref}
    ON CONFLICT (name) DO NOTHING
    """

    run_migration_sql(sql, "contexts metadata", ignore_if_old_missing: true)
  end

  # Uses INSERT INTO...SELECT for singular translations
  defp migrate_singulars_sql(prefix) do
    old_msgs_ref = table_ref("kanta_messages", prefix)
    old_singular_ref = table_ref("kanta_singular_translations", prefix)
    old_locales_ref = table_ref("kanta_locales", prefix)
    old_domains_ref = table_ref("kanta_domains", prefix)
    old_contexts_ref = table_ref("kanta_contexts", prefix)
    new_singular_ref = table_ref(@singular_table, prefix)

    sql = """
    INSERT INTO #{new_singular_ref}
      (locale, domain, msgctxt, msgid, msgstr, msgstr_origin, inserted_at, updated_at)
    SELECT
      l.iso639_code,      -- locale
      COALESCE(d.name, ''), -- domain (use '' if NULL)
      COALESCE(c.name, ''), -- msgctxt (use '' if NULL)
      m.msgid,            -- msgid
      st.translated_text, -- msgstr
      NULL,               -- msgstr_origin (not present in old schema)
      st.inserted_at,
      st.updated_at
    FROM #{old_singular_ref} st
    JOIN #{old_msgs_ref} m ON st.message_id = m.id
    JOIN #{old_locales_ref} l ON st.locale_id = l.id
    LEFT JOIN #{old_domains_ref} d ON m.domain_id = d.id
    LEFT JOIN #{old_contexts_ref} c ON m.context_id = c.id
    WHERE m.message_type = 'singular'
    -- PostgreSQL/SQLite:
    ON CONFLICT (locale, domain, msgctxt, msgid) DO NOTHING
    -- MySQL: Use INSERT IGNORE or handle conflicts differently
    """

    run_migration_sql(sql, "singular translations", ignore_if_old_missing: true)
  end

  # Uses INSERT INTO...SELECT for plural translations
  defp migrate_plurals_sql(prefix) do
    old_msgs_ref = table_ref("kanta_messages", prefix)
    old_plural_ref = table_ref("kanta_plural_translations", prefix)
    old_locales_ref = table_ref("kanta_locales", prefix)
    old_domains_ref = table_ref("kanta_domains", prefix)
    old_contexts_ref = table_ref("kanta_contexts", prefix)
    new_plural_ref = table_ref(@plural_table, prefix)

    sql = """
    INSERT INTO #{new_plural_ref}
      (locale, domain, msgctxt, msgid, msgid_plural, msgstr, plural_index, msgstr_origin, inserted_at, updated_at)
    SELECT
      l.iso639_code,         -- locale
      COALESCE(d.name, ''),    -- domain
      COALESCE(c.name, ''),    -- msgctxt
      m.msgid,               -- msgid (singular form)
      pt.original_text,      -- msgid_plural (assuming this was stored here)
      pt.translated_text,    -- msgstr
      pt.nplural_index,      -- plural_index
      NULL,                  -- msgstr_origin
      pt.inserted_at,
      pt.updated_at
    FROM #{old_plural_ref} pt
    JOIN #{old_msgs_ref} m ON pt.message_id = m.id
    JOIN #{old_locales_ref} l ON pt.locale_id = l.id
    LEFT JOIN #{old_domains_ref} d ON m.domain_id = d.id
    LEFT JOIN #{old_contexts_ref} c ON m.context_id = c.id
    WHERE m.message_type = 'plural'
    -- PostgreSQL/SQLite:
    ON CONFLICT (locale, domain, msgctxt, msgid, msgid_plural, plural_index) DO NOTHING
    -- MySQL: Use INSERT IGNORE or handle conflicts differently
    """

    run_migration_sql(sql, "plural translations", ignore_if_old_missing: true)
  end

  # --- Helper Functions ---

  # Updated helper to run SQL, optionally ignoring "table not found" errors for old tables
  defp run_migration_sql(sql, description, opts) do
    ignore_missing = Keyword.get(opts, :ignore_if_old_missing, false)

    case repo().query(sql, []) do
      {:ok, result} ->
        IO.puts("Successfully migrated #{description}. Rows affected: #{result.num_rows}")

      {:error, reason} ->
        # Check if error is due to a missing table we can ignore
        # Basic error message fetching
        error_msg = Exception.message(reason)
        # Common phrases
        is_missing_table_error =
          String.contains?(error_msg, ["no such table", "does not exist", "doesn't exist"])

        cond do
          ignore_missing and is_missing_table_error ->
            IO.puts(
              "Skipping migration for #{description} as a required old table was not found."
            )

          true ->
            # Actual error, re-raise
            IO.puts("Error migrating #{description}: #{inspect(reason)}")
            raise "Data migration failed for #{description}: #{inspect(reason)}"
        end
    end
  end

  defp quote_identifier(name) do
    ~s("#{String.replace(name, "\"", "\"\"")}")
  end

  defp prefix_ddl(nil), do: ""
  defp prefix_ddl(""), do: ""
  defp prefix_ddl("public"), do: ""
  defp prefix_ddl(prefix), do: ~s(#{quote_identifier(prefix)}.)

  defp table_ref(table_name, prefix) do
    prefix_ddl(prefix) <> quote_identifier(table_name)
  end
end
