defmodule Kanta.PoFiles.MessagesExtractor do
  @moduledoc """
  Handler responsible for extracting data from .po files
  """

  @default_context "default"

  alias Kanta.PoFiles.POFileParser
  alias Kanta.PoFiles.Services.{ExtractPluralTranslation, ExtractSingularTranslation}

  def call do
    # Get config at top level
    otp_name = Kanta.config().otp_name
    allowed_locales = Application.get_env(:kanta, :allowed_locales)

    # Construct full base path including "gettext" subdirectory
    base_path =
      :code.priv_dir(otp_name)
      |> to_string()
      |> Path.join("gettext")

    # Pass explicitly to POFileParser
    result =
      POFileParser.parse_all_po_files(base_path, allowed_locales)
      |> Enum.flat_map(&extract_translations_from_parsed_file/1)

    {:ok, result}
  end

  defp extract_translations_from_parsed_file(%{
         locale: locale,
         domain: domain,
         messages: messages
       }) do
    plurals_header = get_plurals_header(messages, locale)

    messages
    |> Stream.map(fn
      %Expo.Message.Singular{msgctxt: nil, msgid: msgid, msgstr: texts} ->
        ExtractSingularTranslation.call(%{
          msgid: Enum.join(msgid),
          context_name: @default_context,
          locale_name: locale,
          domain_name: domain,
          original_text: Enum.join(texts)
        })

      %Expo.Message.Singular{msgctxt: [msgctxt], msgid: msgid, msgstr: texts} ->
        ExtractSingularTranslation.call(%{
          msgid: Enum.join(msgid),
          context_name: msgctxt,
          locale_name: locale,
          domain_name: domain,
          original_text: Enum.join(texts)
        })

      %Expo.Message.Plural{msgctxt: nil, msgid_plural: msgid, msgstr: plurals_map} ->
        ExtractPluralTranslation.call(%{
          msgid: Enum.join(msgid),
          context_name: @default_context,
          locale_name: locale,
          domain_name: domain,
          plurals_map: plurals_map,
          plurals_header: plurals_header
        })

      %Expo.Message.Plural{msgctxt: [msgctxt], msgid_plural: msgid, msgstr: plurals_map} ->
        ExtractPluralTranslation.call(%{
          msgid: Enum.join(msgid),
          context_name: msgctxt,
          locale_name: locale,
          domain_name: domain,
          plurals_map: plurals_map,
          plurals_header: plurals_header
        })
    end)
    |> Stream.filter(&(!is_nil(&1)))
  end

  defp get_plurals_header(messages, locale) do
    case Expo.PluralForms.plural_form(locale) do
      {:ok, plural_forms} ->
        Expo.PluralForms.to_string(plural_forms)

      :error ->
        Expo.Messages.get_header(messages, "Plural-Forms") |> List.first()
    end
  end
end
