defmodule Kanta.PoFiles.Services.OverwritePoMessage do
  alias Kanta.Translations
  @default_priv "priv/gettext"

  def call(translation, locale, message) do
    priv = Application.get_env(:kanta, :priv, @default_priv)

    domain = Translations.get_domain(message.domain_id)

    original_file_path = Path.join(priv, "#{locale.iso639_code}/LC_MESSAGES/#{domain.name}.po")
    copy_file_path = "#{original_file_path}.copy"

    File.stream!(original_file_path)
    |> Stream.scan("", fn line, acc ->
      if String.match?(acc, ~r"msgid \"#{message.msgid}\"") do
        "msgstr \"#{translation}\"\n"
      else
        line
      end
    end)
    |> Stream.into(File.stream!(copy_file_path))
    |> Stream.run()

    File.rm(original_file_path)
    File.rename(copy_file_path, original_file_path)
  end
end
