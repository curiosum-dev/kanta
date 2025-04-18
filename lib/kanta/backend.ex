defmodule Kanta.Backend do
  @moduledoc """
  Defines the `Kanta.Backend` macro for creating dynamic Gettext backends.

  This module provides the core macro (`use Kanta.Backend`) that allows developers
  to define Gettext backend modules which load translations from dynamic sources
  (like databases) at runtime, rather than relying solely on compiled `.po` files.

  ## Usage

  Instead of `use Gettext.Backend`, use `Kanta.Backend` in your Gettext module definition:

  ```elixir
  defmodule MyApp.Gettext do
    use Kanta.Backend,
      otp_app: :my_app,
      source: Kanta.Backend.Source.Ecto,
      source_opts: [repo: MyApp.Repo]
      # Optional cache:
      # cache: MyApp.GettextCache
  end
  ```

  ## Options

  The `use Kanta.Backend` macro accepts the following options:

  *   `:otp_app` (required): The OTP application name. Used by Gettext infrastructure.
  *   `:priv` (optional): The directory for `.po` files. Defaults to `"priv/gettext"`.
      While Kanta loads dynamically, this is still used by Gettext extraction tools.
  *   `:source` (optional): The module responsible for fetching translations. Must
      implement the `Kanta.Backend.Source` behaviour. Defaults to
      `Kanta.Backend.Source.Ecto`.
  *   `:source_opts` (optional): A keyword list of options passed to the `:source`
      module's `validate_opts/1` and used during runtime lookups. Defaults to `[]`.
      The specific options depend on the chosen `:source` module. For `Ecto`,
      this typically includes `:repo` and `:schema`.
  *   `:cache` (optional): The module responsible for caching translations. Must
      implement the `Kanta.Backend.Cache` behaviour. Defaults to `nil` (no caching).
  *   `:plural_forms` (optional): The module responsible for determining plural forms.
      Defaults to `Gettext.Plural`. Must implement the `Gettext.Plural` behaviour.
  *   `:interpolation` (optional): The module responsible for string interpolation.
      Defaults to `Gettext.Interpolation.Default`. Must implement the
      `Gettext.Interpolation` behaviour.
  *   `:default_locale` (optional): The default locale. Defaults to `"en"`.
  *   `:default_domain` (optional): The default domain. Defaults to `"default"`.

  Any other options are passed directly to `use Gettext.Backend` when running in
  extraction mode.

  ## Kanta.Backend Behaviour

  Modules using `Kanta.Backend` implicitly implement the `Kanta.Backend` behaviour,
  which currently requires the `source_opts/0` callback. This callback returns the
  `:source_opts` configured during `use`.
  """

  @callback source_opts() :: Keyword.t()

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts, caller: __MODULE__] do
      require Logger
      # Flag file setup remains the same
      @flag_file Path.join([
                   "priv/kanta/",
                   Kanta.Utils.ModuleFolder.safe_folder_name(__MODULE__),
                   ".gettext_recompiled"
                 ])
      gettext_opts = Keyword.drop(opts, [:source, :cache, :source_opts])

      # Store modules and config for runtime use
      @kanta_source Keyword.get(opts, :source, Kanta.Backend.Source.Ecto)
      @kanta_source_opts Keyword.get(opts, :source_opts, [])
      @plural_forms Keyword.get(opts, :plural_forms, Gettext.Plural)
      @interpolation Keyword.get(opts, :interpolation, Gettext.Interpolation.Default)
      # Default to nil
      @kanta_cache Keyword.get(opts, :cache, nil)

      def __mix_recompile__?() do
        Kanta.Utils.GettextRecompiler.needs_recompile?(@flag_file)
      end

      if Gettext.Extractor.extracting?() do
        use Gettext.Backend, gettext_opts
        Kanta.Utils.GettextRecompiler.setup_recompile_flag(@flag_file)
      else
        # --- Runtime Logic (Delegates to Kanta.Backend.Lookup) ---
        @behaviour Gettext.Backend
        @behaviour Kanta.Backend

        # --- Basic Gettext Callbacks ---
        def __gettext__(:priv), do: unquote(Keyword.get(opts, :priv, "priv/gettext"))
        def __gettext__(:otp_app), do: unquote(Keyword.fetch!(opts, :otp_app))
        def __gettext__(:known_locales), do: @kanta_source.known_locales(__MODULE__)
        def __gettext__(:default_locale), do: unquote(Keyword.get(opts, :default_locale, "en"))

        def __gettext__(:default_domain),
          do: unquote(Keyword.get(opts, :default_domain, "default"))

        def __gettext__(:interpolation), do: @interpolation

        # --- Kanta Backend Callback---
        @impl Kanta.Backend
        def source_opts(), do: @kanta_source_opts

        # --- Source Validation ---
        @kanta_source.validate_opts(@kanta_source_opts)

        # --- Core Gettext Backend Implementations (Delegate to Lookup Module) ---

        @impl Gettext.Backend
        def lgettext(locale, domain, msgctx, msgid, bindings) do
          # Delegate core logic to the Lookup module
          Kanta.Backend.Lookup.lgettext(
            # Pass self for callbacks
            __MODULE__,
            @kanta_source,
            @kanta_cache,
            @interpolation,
            locale,
            domain,
            msgctx,
            msgid,
            bindings
          )
        end

        @impl Gettext.Backend
        def lngettext(locale, domain, msgctx, msgid, msgid_plural, n, bindings) do
          # Delegate core logic to the Lookup module
          Kanta.Backend.Lookup.lngettext(
            # Pass self for callbacks
            __MODULE__,
            @kanta_source,
            @kanta_cache,
            @interpolation,
            @plural_forms,
            locale,
            domain,
            msgctx,
            msgid,
            msgid_plural,
            n,
            bindings
          )
        end

        # --- Default Handlers and Overridables  ---
        # These provide the *default* implementation for this specific backend module
        # and allow users to override them directly in their Gettext module.
        # Kanta.Backend.Lookup calls these functions via the `backend_module` argument.

        @impl true
        def handle_missing_bindings(exception, incomplete) do
          _ = Logger.error(Exception.message(exception))
          incomplete
        end

        @impl true
        def handle_missing_translation(_locale, _domain, _msgctxt, msgid, bindings) do
          # Interpolate the original msgid as fallback
          with {:ok, interpolated} <- @interpolation.runtime_interpolate(msgid, bindings),
               do: {:default, interpolated}
        end

        @impl true
        def handle_missing_plural_translation(
              _locale,
              _domain,
              _msgctxt,
              msgid,
              msgid_plural,
              n,
              # These are the extended bindings passed from Lookup
              bindings
            ) do
          string = if n == 1, do: msgid, else: msgid_plural
          # Bindings already include :count
          with {:ok, interpolated} <- @interpolation.runtime_interpolate(string, bindings),
               do: {:default, interpolated}
        end

        # Make the default handlers overridable in the user's module
        defoverridable handle_missing_bindings: 2,
                       handle_missing_translation: 5,
                       handle_missing_plural_translation: 7
      end
    end
  end
end
