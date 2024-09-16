defmodule Kanta.POFiles.MessagesExtractor do
  @moduledoc """
  Handler responsible for extracting data from .po files
  """

  @po_wildcard "**/*.po"

  alias Expo.{Messages, PO}

  alias Kanta.PoFiles.Services.{ExtractPluralTranslation, ExtractSingularTranslation}

  def call do
    opts = [
      otp_name: Kanta.config().otp_name,
      allowed_locales: Application.get_env(:kanta, :allowed_locales)
    ]

    priv = :code.priv_dir(opts[:otp_name])
    priv_gettext_po_files = po_files_in_priv(priv)
    known_po_files = known_po_files(priv_gettext_po_files, opts)

    extract_translations(known_po_files)
  end

  defp extract_translations(known_po_files) do
    known_po_files
    |> Enum.flat_map(&extract_translations_from_file(&1))
  end

  defp extract_translations_from_file(po_file) do
    %{locale: locale, domain: domain, path: path} = po_file
    %Messages{messages: messages} = messages_struct = PO.parse_file!(path)

    plurals_header = get_plurals_header(messages_struct, locale)

    messages
    |> Stream.map(fn
      %Expo.Message.Singular{msgctxt: nil, msgid: [msgid], msgstr: texts} ->
        ExtractSingularTranslation.call(%{
          msgid: msgid,
          locale_name: locale,
          domain_name: domain,
          original_text: Enum.join(texts)
        })

      %Expo.Message.Singular{msgctxt: [msgctxt], msgid: [msgid], msgstr: texts} ->
        ExtractSingularTranslation.call(%{
          msgid: msgid,
          context_name: msgctxt,
          locale_name: locale,
          domain_name: domain,
          original_text: Enum.join(texts)
        })

      %Expo.Message.Plural{msgctxt: nil, msgid_plural: [msgid], msgstr: plurals_map} ->
        ExtractPluralTranslation.call(%{
          msgid: msgid,
          locale_name: locale,
          domain_name: domain,
          plurals_map: plurals_map,
          plurals_header: plurals_header
        })

      %Expo.Message.Plural{msgctxt: [msgctxt], msgid_plural: [msgid], msgstr: plurals_map} ->
        ExtractPluralTranslation.call(%{
          msgid: msgid,
          context_name: msgctxt,
          locale_name: locale,
          domain_name: domain,
          plurals_map: plurals_map,
          plurals_header: plurals_header
        })
    end)
    |> Stream.filter(&(!is_nil(&1)))
  end

  defp locale_and_domain_from_path(path) do
    [file, "LC_MESSAGES", locale | _rest] = path |> Path.split() |> Enum.reverse()
    domain = Path.rootname(file, ".po")
    {locale, domain}
  end

  defp po_files_in_priv(priv) do
    priv
    |> Path.join("gettext")
    |> Path.join(@po_wildcard)
    |> Path.wildcard()
  end

  defp known_po_files(all_po_files, opts) do
    all_po_files
    |> Enum.map(fn path ->
      {locale, domain} = locale_and_domain_from_path(path)
      %{locale: locale, path: path, domain: domain}
    end)
    |> maybe_restrict_locales(opts[:allowed_locales])
  end

  defp maybe_restrict_locales(po_files, nil) do
    po_files
  end

  defp maybe_restrict_locales(po_files, allowed_locales) when is_list(allowed_locales) do
    allowed_locales = MapSet.new(Enum.map(allowed_locales, &to_string/1))
    Enum.filter(po_files, &MapSet.member?(allowed_locales, &1[:locale]))
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
