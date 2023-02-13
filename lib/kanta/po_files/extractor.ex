defmodule Kanta.POFiles.Extractor do
  @default_priv "priv/gettext"
  @po_wildcard "*/LC_MESSAGES/*.po"

  alias Kanta.Repo
  alias Expo.{Message, Messages, PO}
  alias Kanta.Translations.Domains
  alias Kanta.Translations.Locales
  alias Kanta.Translations.SingularTranslation

  def get_translations do
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
    %Messages{messages: messages} = PO.parse_file!(path)

    messages
    |> Stream.map(fn
      %Message.Singular{msgctxt: nil, msgid: [msgid], msgstr: [text]} ->
        create_or_update_singular_translation(%{
          locale: locale,
          domain: domain,
          msgid: msgid,
          text: text
        })

      %Message.Singular{msgctxt: [msgctxt], msgid: [msgid], msgstr: [text]} ->
        create_or_update_singular_translation(%{
          locale: locale,
          domain: domain,
          msgctxt: msgctxt,
          msgid: msgid,
          text: text
        })

      _ ->
        nil
    end)
    |> Stream.filter(&(!is_nil(&1)))
  end

  defp create_or_update_singular_translation(attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:locale, fn _repo, _ ->
      {:ok, Locales.get_or_create_locale_by_name(attrs[:locale])}
    end)
    |> Ecto.Multi.run(:domain, fn _repo, _ ->
      {:ok, Domains.get_or_create_domain_by_name(attrs[:domain])}
    end)
    |> Ecto.Multi.run(:translation_struct, fn repo, _ ->
      {:ok,
       repo.get_by(SingularTranslation, msgid: attrs[:msgid]) ||
         %SingularTranslation{}}
    end)
    |> Ecto.Multi.insert_or_update(:insert_or_update_translation, fn %{
                                                                       locale: locale,
                                                                       domain: domain,
                                                                       translation_struct:
                                                                         translation_struct
                                                                     } ->
      SingularTranslation.changeset(
        translation_struct,
        Map.merge(attrs, %{locale_id: locale.id, domain_id: domain.id})
      )
    end)
    |> Repo.get_repo().transaction()
    |> case do
      {:ok, %{insert_or_update_translation: %SingularTranslation{} = translation}} -> translation
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
end
