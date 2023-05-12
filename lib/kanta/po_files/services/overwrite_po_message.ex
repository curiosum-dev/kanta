defmodule Kanta.PoFiles.Services.OverwritePoMessage do
  alias Kanta.Translations
  @default_priv "priv/gettext"

  def singular(translation, locale, message) do
    priv = Application.get_env(:kanta, :priv, @default_priv)

    {:ok, domain} = Translations.get_domain(filter: [id: message.domain_id])

    original_file_path = Path.join(priv, "#{locale.iso639_code}/LC_MESSAGES/#{domain.name}.po")
    copy_file_path = "#{original_file_path}.copy"

    File.stream!(original_file_path)
    |> Stream.scan("", fn line, acc ->
      if String.match?(acc, ~r"msgid \"#{message.msgid}\"") do
        "msgstr \"#{String.replace(translation, ~w["], "'", global: true)}\"\n"
      else
        line
      end
    end)
    |> Stream.into(File.stream!(copy_file_path))
    |> Stream.run()

    File.rm(original_file_path)
    File.rename(copy_file_path, original_file_path)
  end

  def plural(translation, nplural_index, locale, message) do
    priv = Application.get_env(:kanta, :priv, @default_priv)
    {:ok, domain} = Translations.get_domain(filter: [id: message.domain_id])
    original_file_path = Path.join(priv, "#{locale.iso639_code}/LC_MESSAGES/#{domain.name}.po")
    copy_file_path = "#{original_file_path}.copy"

    %Expo.Messages{messages: messages} = po_file = Expo.PO.parse_file!(original_file_path)

    messages =
      messages
      |> Enum.map(fn expo_message ->
        case expo_message do
          %Expo.Message.Plural{msgid_plural: plural_ids} = po_message ->
            if message.msgid in plural_ids do
              Map.replace!(
                po_message,
                :msgstr,
                Map.replace!(po_message.msgstr, nplural_index, [translation])
              )
            else
              po_message
            end

          po_message ->
            po_message
        end
      end)

    po_file = Map.put(po_file, :messages, messages)

    File.write!(copy_file_path, Expo.PO.compose(po_file))
    File.rm(original_file_path)
    File.rename(copy_file_path, original_file_path)
  end
end
