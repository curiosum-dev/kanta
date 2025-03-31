defmodule Kanta.Utils.GettextRecompiler do
  require Logger

  def setup_recompile_flag(flag_file) do
    if Gettext.Extractor.extracting?() do
      File.mkdir_p!(Path.dirname(flag_file))
      File.touch!(flag_file)
    end
  end

  def needs_recompile?(flag_file) do
    if !Gettext.Extractor.extracting?() && File.exists?(flag_file) do
      File.rm(flag_file)
      true
    else
      false
    end
  end
end
