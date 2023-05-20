defmodule Kanta.Translations.Locale.Services.CreateLocaleFromIsoCode do
  @moduledoc """
  Service for mapping locale iso639 code to the Kanta locale
  """

  alias Kanta.Repo

  alias Kanta.Translations.Locale

  alias Kanta.Translations.Locale.Utils.LocaleCodeMapper

  def call(iso_code) do
    %Locale{}
    |> Locale.changeset(mapped_attrs(iso_code))
    |> Repo.get_repo().insert()
  end

  defp mapped_attrs(iso_code) do
    %{
      "iso639_code" => iso_code,
      "name" => LocaleCodeMapper.get_name(iso_code),
      "native_name" => LocaleCodeMapper.get_native_name(iso_code),
      "family" => LocaleCodeMapper.get_family(iso_code),
      "wiki_url" => LocaleCodeMapper.get_wiki_url(iso_code),
      "colors" => LocaleCodeMapper.get_colors(iso_code)
    }
  end
end
