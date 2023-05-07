defmodule Kanta.POFiles.Extractor do
  @default_priv "priv/gettext"
  @po_wildcard "*/LC_MESSAGES/*.po"

  alias Kanta.Repo
  alias Expo.{Messages, PO}
  alias Kanta.Translations.{Contexts, Domains, Locales}
  alias Kanta.Translations.{Message, PluralTranslation, SingularTranslation}

  def parse_translations do
    opts = [
      project_root: Application.fetch_env!(:kanta, :project_root),
      priv: Application.get_env(:kanta, :priv, @default_priv),
      allowed_locales: Application.get_env(:kanta, :allowed_locales)
    ]

    priv = Path.join(opts[:project_root], opts[:priv])
    all_po_files = po_files_in_priv(priv)
    known_po_files = known_po_files(all_po_files, opts)

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
      %Expo.Message.Singular{msgctxt: nil, msgid: [msgid], msgstr: [text]} ->
        create_or_update_singular_translation(%{
          msgid: msgid,
          locale_name: locale,
          domain_name: domain,
          original_text: text
        })

      %Expo.Message.Singular{msgctxt: [msgctxt], msgid: [msgid], msgstr: [text]} ->
        create_or_update_singular_translation(%{
          msgid: msgid,
          context_name: msgctxt,
          locale_name: locale,
          domain_name: domain,
          original_text: text
        })

      %Expo.Message.Plural{msgctxt: nil, msgid_plural: [msgid], msgstr: plurals_map} ->
        create_or_update_plural_translation(%{
          msgid: msgid,
          locale_name: locale,
          domain_name: domain,
          plurals_map: plurals_map,
          plurals_header: plurals_header
        })

      %Expo.Message.Plural{msgctxt: [msgctxt], msgid_plural: [msgid], msgstr: plurals_map} ->
        create_or_update_plural_translation(%{
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

  defp create_or_update_message(multi, attrs) do
    multi
    |> Ecto.Multi.run(:domain, fn _repo, _ ->
      if is_nil(attrs[:domain_name]) do
        {:ok, nil}
      else
        {:ok, Domains.get_or_create_domain_by(name: attrs[:domain_name])}
      end
    end)
    |> Ecto.Multi.run(:context, fn _repo, _ ->
      if is_nil(attrs[:context_name]) do
        {:ok, nil}
      else
        {:ok, Contexts.get_or_create_context_by(name: attrs[:context_name])}
      end
    end)
    |> Ecto.Multi.run(:message, fn repo, _ ->
      {:ok,
       repo.get_by(Message, msgid: attrs[:msgid], message_type: attrs[:message_type]) ||
         %Message{}}
    end)
    |> Ecto.Multi.insert_or_update(:insert_or_update_message, fn %{
                                                                   message: message,
                                                                   domain: domain,
                                                                   context: context
                                                                 } ->
      attrs =
        unless is_nil(domain) do
          Map.merge(attrs, %{domain_id: domain.id})
        else
          attrs
        end

      attrs =
        unless is_nil(context) do
          Map.merge(attrs, %{context_id: context.id})
        else
          attrs
        end

      Message.changeset(
        message,
        attrs
      )
    end)
  end

  defp create_or_update_singular_translation(attrs) do
    Ecto.Multi.new()
    |> create_or_update_message(Map.merge(attrs, %{message_type: :singular}))
    |> Ecto.Multi.run(:locale, fn _repo, _ ->
      {:ok, Locales.get_or_create_locale_by(iso639_code: attrs[:locale_name])}
    end)
    |> Ecto.Multi.run(:translation_struct, fn repo,
                                              %{insert_or_update_message: message, locale: locale} ->
      {:ok,
       repo.get_by(SingularTranslation, message_id: message.id, locale_id: locale.id) ||
         %SingularTranslation{}}
    end)
    |> Ecto.Multi.insert_or_update(:insert_or_update_translation, fn %{
                                                                       insert_or_update_message:
                                                                         message,
                                                                       locale: locale,
                                                                       translation_struct:
                                                                         translation_struct
                                                                     } ->
      SingularTranslation.changeset(
        translation_struct,
        Map.merge(attrs, %{message_id: message.id, locale_id: locale.id})
      )
    end)
    |> Repo.get_repo().transaction()
    |> case do
      {:ok, %{insert_or_update_translation: %SingularTranslation{} = translation}} -> translation
      _ -> nil
    end
  end

  defp create_or_update_plural_translation(attrs) do
    Ecto.Multi.new()
    |> create_or_update_message(
      Map.merge(attrs, %{message_type: :plural, plurals_header: attrs[:plurals_header]})
    )
    |> Ecto.Multi.run(:locale, fn _repo, _ ->
      {:ok, Locales.get_or_create_locale_by(iso639_code: attrs[:locale_name])}
    end)
    |> Ecto.Multi.run(:translation_structs, fn repo,
                                               %{
                                                 insert_or_update_message: message,
                                                 locale: locale
                                               } ->
      {:ok,
       Enum.map(attrs[:plurals_map], fn {index, original_text} ->
         struct =
           repo.get_by(PluralTranslation,
             nplural_index: index,
             message_id: message.id,
             locale_id: locale.id
           ) || %PluralTranslation{}

         PluralTranslation.changeset(struct, %{
           nplural_index: index,
           message_id: message.id,
           locale_id: locale.id,
           original_text: List.first(original_text)
         })
         |> repo.insert_or_update
       end)}
    end)
    |> Repo.get_repo().transaction()
    |> case do
      {:ok, %{translation_structs: structs}} -> structs
      _ -> nil
    end
  end

  defp locale_and_domain_from_path(path) do
    [file, "LC_MESSAGES", locale | _rest] = path |> Path.split() |> Enum.reverse()
    domain = Path.rootname(file, ".po")
    {locale, domain}
  end

  defp po_files_in_priv(priv) do
    priv
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
    plurals_header = Expo.Messages.get_header(messages, "Plural-Forms") |> List.first()

    plurals_header ||
      Expo.PluralForms.plural_form(locale) |> elem(1) |> Expo.PluralForms.to_string()
  end
end
