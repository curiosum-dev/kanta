defmodule Kanta.Backend.Source.Ecto do
  @moduledoc """
  A Kanta adapter implementation that uses an Ecto-backed database for translation storage.

  This adapter implements the `Kanta.Backend.Source` behaviour by storing and retrieving
  translations from database tables. It supports both singular and plural translations,
  context-based translations, and provides functions to determine available locales.

  ## Configuration

  To use this adapter, you need to configure the repository to use:

  ```elixir
  config :kanta, Kanta.Backend.Source.Ecto,
    repo: MyApp.Repo
  ```

  """
  @behaviour Kanta.Backend.Source
  import Ecto.Query
  require Logger

  alias Kanta.DataAccess.Adapter.Ecto.Singular
  alias Kanta.DataAccess.Adapter.Ecto.Plural

  @doc """
  Looks up a singular translation in the database based on the provided parameters.

  ## Parameters

    * `locale` - The language code (e.g., "en", "fr") for which to find the translation
    * `domain` - The domain/category of the message (e.g., "default", "errors")
    * `msgctxt` - Optional context to disambiguate messages with the same text but different meanings
      (can be `nil` or a binary string)
    * `msgid` - The original message ID that serves as the lookup key

  ## Returns

    * `{:ok, msgstr}` - When the translation is found
    * `{:error, :not_found}` - When no matching translation exists for the given parameters

  The function performs an exact match lookup on the provided locale, domain, msgid, and optional
  msgctxt to find the appropriate translation in the database.
  """

  @impl true
  def lookup_lgettext(backend, locale, domain, msgctxt, msgid)
      when is_atom(backend) and is_binary(locale) and is_binary(domain) and is_binary(msgid) do
    singular_schema = Singular
    repo = config!(backend, :repo)

    query =
      singular_schema
      |> where([t], t.locale == ^locale)
      |> where([t], t.domain == ^domain)
      |> where([t], t.msgid == ^msgid)
      |> where_msgctxt(msgctxt)
      |> select([t], t.msgstr)

    case repo.one(query) do
      nil ->
        {:error, :not_found}

      msgstr when is_binary(msgstr) ->
        {:ok, msgstr}

      other ->
        Logger.error("Ecto Source: Unexpected result for singular lookup: #{inspect(other)}")
        {:error, :not_found}
    end
  end

  @doc """
  Looks up a plural translation in the database based on the provided parameters.

  ## Parameters

    * `locale` - The language code (e.g., "en", "fr") for which to find the translation
    * `domain` - The domain/category of the message (e.g., "default", "errors")
    * `msgctxt` - Optional context to disambiguate messages with the same text but different meanings
      (can be `nil` or a binary string)
    * `msgid` - The original singular message ID that serves as the lookup key
    * `msgid_plural` - The original plural message ID
    * `plural_index` - Integer index (0, 1, 2, etc.) of the plural form to retrieve, as determined by the plural rules for the given locale and count

  ## Returns

    * `{:ok, msgstr}` - When the translation for the specified plural form is found
    * `{:error, :not_found}` - When no matching translation exists for the given parameters

  The function specifically looks for an exact match on all parameters, including the plural_index.
  If any part of the query doesn't match (including if a different plural form exists but not the
  requested one), it will return `{:error, :not_found}`.
  """
  @impl true
  def lookup_lngettext(backend, locale, domain, msgctxt, msgid, _msgid_plural, plural_index)
      when is_atom(backend) and is_binary(locale) and is_binary(domain) and is_binary(msgid) and
             is_integer(plural_index) and plural_index >= 0 do
    plural_schema = Plural
    repo = config!(backend, :repo)

    query =
      plural_schema
      |> where([t], t.locale == ^locale)
      |> where([t], t.domain == ^domain)
      |> where([t], t.msgid == ^msgid)
      |> where([t], t.plural_index == ^plural_index)
      |> where_msgctxt(msgctxt)
      |> select([t], t.msgstr)

    case repo.one(query) do
      nil ->
        # This *specifically* means the required form (index) for this message wasn't found
        {:error, :not_found}

      msgstr when is_binary(msgstr) ->
        # Found the specific string for the requested index
        {:ok, msgstr}

      other ->
        # Should not happen
        Logger.error("Ecto Source: Unexpected result for plural lookup: #{inspect(other)}")
        {:error, :not_found}
    end
  end

  @impl true
  def known_locales(backend) when is_atom(backend) do
    repo = config!(backend, :repo)

    singular_locale =
      from(s in Singular, distinct: [s.locale], select: s.locale)

    plural_locale =
      from(p in Plural, distinct: [p.locale], select: p.locale)

    union(singular_locale, ^plural_locale)
    |> repo.all()
  end

  @impl true
  def validate_opts(opts) do
    case Keyword.fetch(opts, :repo) do
      {:ok, repo} when is_atom(repo) ->
        opts

      _ ->
        raise ArgumentError,
              "Kanta Ecto adapter requires :repo option to be set to a module name"
    end
  end

  defp config!(backend, key) when is_atom(backend) do
    try do
      backend.source_opts() |> Keyword.fetch!(key)
    rescue
      ArgumentError ->
        raise "Missing Kanta Ecto adapter configuration for key :#{key} under `use #{backend}, ... , source: #{__MODULE__}, source_opts: [...]`"
    end
  end

  # where_msgctxt/2 helper (Unchanged)
  defp where_msgctxt(query, nil) do
    where(query, [t], is_nil(t.msgctxt))
  end

  defp where_msgctxt(query, msgctxt) when is_binary(msgctxt) do
    where(query, [t], t.msgctxt == ^msgctxt)
  end
end
