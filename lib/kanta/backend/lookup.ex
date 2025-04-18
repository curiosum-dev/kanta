defmodule Kanta.Backend.Lookup do
  @moduledoc """
  Handles the core translation lookup logic for Kanta.Backend.

  This module encapsulates fetching translations from the source,
  interacting with the cache (if configured), handling pluralization,
  interpolation, and calling back to the Gettext backend module
  for missing translation handling. It also caches missing translation lookups
  to avoid repeated source queries.
  """
  require Logger

  @not_found_marker :__kanta_translation_not_found__

  # --- Public API ---

  @doc """
  Performs lookup for a singular translation (`lgettext`).

  Handles caching (including missing lookups) if `cache_module` is provided.
  Calls back to `backend_module.handle_missing_translation/5` on lookup failure.
  """
  def lgettext(
        backend_module,
        source_module,
        cache_module,
        interpolation_module,
        locale,
        domain,
        msgctx,
        msgid,
        bindings
      ) do
    do_lgettext(
      cache_module,
      backend_module,
      source_module,
      interpolation_module,
      locale,
      domain,
      msgctx,
      msgid,
      bindings
    )
  end

  @doc """
  Performs lookup for a plural translation (`lngettext`).

  Handles caching (including missing lookups) if `cache_module` is provided.
  Calls back to `backend_module.handle_missing_plural_translation/7` on lookup failure.
  """
  def lngettext(
        backend_module,
        source_module,
        cache_module,
        interpolation_module,
        plural_forms_module,
        locale,
        domain,
        msgctx,
        msgid,
        msgid_plural,
        n,
        bindings
      ) do
    plural_index = pluralize(plural_forms_module, locale, n)
    extended_bindings = Map.put(bindings, :count, n)

    do_lngettext(
      cache_module,
      backend_module,
      source_module,
      interpolation_module,
      locale,
      domain,
      msgctx,
      msgid,
      msgid_plural,
      plural_index,
      n,
      extended_bindings
    )
  end

  # --- Private Helpers ---

  defp cache_key(input), do: :erlang.phash2(input)

  # No cache
  defp do_lgettext(
         # no cache
         nil,
         backend_module,
         source_module,
         interpolation_module,
         locale,
         domain,
         msgctx,
         msgid,
         bindings
       ) do
    lookup_lgettext_in_source(
      # cache_info
      nil,
      backend_module,
      source_module,
      interpolation_module,
      locale,
      domain,
      msgctx,
      msgid,
      bindings
    )
  end

  # With cache
  defp do_lgettext(
         cache_module,
         backend_module,
         source_module,
         interpolation_module,
         locale,
         domain,
         msgctx,
         msgid,
         bindings
       )
       when is_atom(cache_module) do
    key = cache_key({backend_module, locale, domain, msgctx, msgid})
    cached_value = cache_module.get(key)

    case cached_value do
      @not_found_marker ->
        backend_module.handle_missing_translation(locale, domain, msgctx, msgid, bindings)

      raw_msgstr when is_binary(raw_msgstr) ->
        interpolate(interpolation_module, raw_msgstr, bindings)

      # Cache miss
      _ ->
        lookup_lgettext_in_source(
          # cache_info
          {cache_module, key},
          backend_module,
          source_module,
          interpolation_module,
          locale,
          domain,
          msgctx,
          msgid,
          bindings
        )
    end
  end

  # No cache
  defp do_lngettext(
         # No cache
         nil,
         backend_module,
         source_module,
         interpolation_module,
         locale,
         domain,
         msgctx,
         msgid,
         msgid_plural,
         plural_index,
         n,
         extended_bindings
       ) do
    lookup_lngettext_in_source(
      # cache_info
      nil,
      backend_module,
      source_module,
      interpolation_module,
      locale,
      domain,
      msgctx,
      msgid,
      msgid_plural,
      plural_index,
      n,
      extended_bindings
    )
  end

  # With cache
  defp do_lngettext(
         cache_module,
         backend_module,
         source_module,
         interpolation_module,
         locale,
         domain,
         msgctx,
         msgid,
         msgid_plural,
         plural_index,
         n,
         extended_bindings
       )
       when is_atom(cache_module) do
    key =
      cache_key({backend_module, locale, domain, msgctx, msgid, msgid_plural, plural_index})

    cached_value = cache_module.get(key)

    case cached_value do
      @not_found_marker ->
        backend_module.handle_missing_plural_translation(
          locale,
          domain,
          msgctx,
          msgid,
          msgid_plural,
          n,
          extended_bindings
        )

      raw_msgstr when is_binary(raw_msgstr) ->
        interpolate(interpolation_module, raw_msgstr, extended_bindings)

      # Cache miss
      _ ->
        lookup_lngettext_in_source(
          # cache_info
          {cache_module, key},
          backend_module,
          source_module,
          interpolation_module,
          locale,
          domain,
          msgctx,
          msgid,
          msgid_plural,
          plural_index,
          n,
          extended_bindings
        )
    end
  end

  # --- Source Lookup & Cache Handling ---

  # Performs the actual source lookup for lgettext, caches if cache_info is provided
  defp lookup_lgettext_in_source(
         # {cache_module, key} | nil
         cache_info,
         backend_module,
         source_module,
         interpolation_module,
         locale,
         domain,
         msgctx,
         msgid,
         bindings
       ) do
    case source_module.lookup_lgettext(backend_module, locale, domain, msgctx, msgid) do
      {:ok, raw_msgstr} ->
        # <--- Use helper
        maybe_put_in_cache(cache_info, raw_msgstr)
        interpolate(interpolation_module, raw_msgstr, bindings)

      {:error, :not_found} ->
        # <--- Use helper
        maybe_put_in_cache(cache_info, @not_found_marker)
        backend_module.handle_missing_translation(locale, domain, msgctx, msgid, bindings)
    end
  end

  # Performs the actual source lookup for lngettext, caches if cache_info is provided
  defp lookup_lngettext_in_source(
         # {cache_module, key} | nil
         cache_info,
         backend_module,
         source_module,
         interpolation_module,
         locale,
         domain,
         msgctx,
         msgid,
         msgid_plural,
         plural_index,
         n,
         extended_bindings
       ) do
    case source_module.lookup_lngettext(
           backend_module,
           locale,
           domain,
           msgctx,
           msgid,
           msgid_plural,
           plural_index
         ) do
      {:ok, raw_msgstr} ->
        maybe_put_in_cache(cache_info, raw_msgstr)
        interpolate(interpolation_module, raw_msgstr, extended_bindings)

      {:error, :not_found} ->
        maybe_put_in_cache(cache_info, @not_found_marker)

        backend_module.handle_missing_plural_translation(
          locale,
          domain,
          msgctx,
          msgid,
          msgid_plural,
          n,
          extended_bindings
        )
    end
  end

  # --- Cache Helper ---

  # Puts the given value into the cache if caching is enabled.
  defp maybe_put_in_cache(cache_info, value_to_cache) do
    case cache_info do
      {cache_module, key} -> cache_module.put(key, value_to_cache)
      # If cache_info is nil (caching disabled), do nothing.
      nil -> :ok
    end
  end

  # --- Utility Helpers ---

  # Helper to apply pluralization using the configured module and LOCALE.
  defp pluralize(plural_forms_module, locale, n) when is_binary(locale) and is_integer(n) do
    try do
      plural_forms_module.plural(locale, n)
    catch
      kind, reason ->
        Logger.error("""
        Kanta: Error calling plural function (#{plural_forms_module}.plural/2) \
        with locale=#{inspect(locale)}, n=#{n}. \
        Error: #{kind} - #{inspect(reason)}. \
        Returning default plural index 0.
        """)

        0
    end
  end

  # Helper to apply interpolation using the configured module at RUNTIME.
  defp interpolate(interpolation_module, raw_msgstr, bindings) when is_binary(raw_msgstr) do
    interpolation_module.runtime_interpolate(raw_msgstr, bindings)
  end
end
