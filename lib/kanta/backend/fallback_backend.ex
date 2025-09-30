defmodule Kanta.Backend.GettextFallback do
  @moduledoc """
  Provides a fallback mechanism to Gettext's PO files translation system.

  This module creates a nested Gettext backend that is used when database
  translations are not found. It allows Kanta to gracefully fall back to
  standard PO file translations when a specific translation is not available
  in the database.
  """

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      defmodule GettextFallbackBackend do
        @moduledoc false

        require Logger
        @flag_file "priv/kanta/.fallback_recompiled"

        # When `mix gettext extract` create empty stub so that the  Kanta.Backend can compile.
        if Gettext.Extractor.extracting?() do
          def lgettext(_locale, _domain, _msgctxt, _msgid, _bindings), do: nil
          def lngettext(_locale, _domain, _msgctxt, _msgid, _msgid_plural, _n, _bindings), do: nil

          Kanta.Utils.GettextRecompiler.setup_recompile_flag(@flag_file)
        else
          # ...otherwise generate the Gettext.Backend interface
          use Gettext.Backend, opts
        end

        def __mix_recompile__?() do
          Kanta.Utils.GettextRecompiler.needs_recompile?(@flag_file)
        end
      end
    end
  end
end
