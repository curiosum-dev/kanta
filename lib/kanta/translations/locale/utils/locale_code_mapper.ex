defmodule Kanta.Translations.Locale.Utils.LocaleCodeMapper do
  @moduledoc """
  Utility for mapping locales data from iso code
  """

  def get_native_name(code) do
    dictionary_file = Application.app_dir(:kanta, "priv/iso639.json")
    dictionary = Jason.decode!(File.read!(dictionary_file))

    case Map.fetch(dictionary, code) do
      {:ok, info} -> info["nativeName"]
      _ -> "unknown"
    end
  end

  def get_name(code) do
    dictionary_file = Application.app_dir(:kanta, "priv/iso639.json")
    dictionary = Jason.decode!(File.read!(dictionary_file))

    case Map.fetch(dictionary, code) do
      {:ok, info} -> info["name"]
      _ -> "unknown"
    end
  end

  def get_family(code) do
    dictionary_file = Application.app_dir(:kanta, "priv/iso639.json")
    dictionary = Jason.decode!(File.read!(dictionary_file))

    case Map.fetch(dictionary, code) do
      {:ok, info} -> info["family"]
      _ -> "unknown"
    end
  end

  def get_wiki_url(code) do
    dictionary_file = Application.app_dir(:kanta, "priv/iso639.json")
    dictionary = Jason.decode!(File.read!(dictionary_file))

    case Map.fetch(dictionary, code) do
      {:ok, info} -> info["wikiUrl"]
      _ -> "unknown"
    end
  end

  def get_colors(code) do
    dictionary_file = Application.app_dir(:kanta, "priv/iso639.json")
    dictionary = Jason.decode!(File.read!(dictionary_file))

    case Map.fetch(dictionary, code) do
      {:ok, info} -> info["colors"]
      _ -> "unknown"
    end
  end
end
