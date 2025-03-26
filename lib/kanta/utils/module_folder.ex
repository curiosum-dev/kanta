defmodule Kanta.Utils.ModuleFolder do
  @doc """
  Converts a module name to a safe folder name.

  ## Options
  - `:lowercase` - Set to `true` to convert to lowercase (default: `false`)
  - `:replace_with` - Character to replace invalid chars with (default: `"_"`)

  ## Examples
      iex> ModuleFolder.safe_folder_name(MyApp.UserSchema)
      "my_app_user_schema"

      iex> ModuleFolder.safe_folder_name(MyApp.UserSchema, lowercase: false)
      "MyApp_UserSchema"

      iex> ModuleFolder.safe_folder_name("Elixir.MyApp.Module", replace_with: "-")
      "MyApp-Module"
  """
  def safe_folder_name(module, opts \\ []) when is_atom(module) or is_binary(module) do
    lowercase? = Keyword.get(opts, :lowercase, true)
    replacement = Keyword.get(opts, :replace_with, "_")

    module
    |> module_to_string()
    |> remove_elixir_prefix()
    |> replace_invalid_chars(replacement)
    |> maybe_downcase(lowercase?)
  end

  defp module_to_string(module) when is_atom(module), do: Atom.to_string(module)
  defp module_to_string(module) when is_binary(module), do: module

  defp remove_elixir_prefix("Elixir." <> rest), do: rest
  defp remove_elixir_prefix(other), do: other

  defp replace_invalid_chars(name, replacement) do
    # Replace characters that are invalid in folder names
    name
    |> String.replace(~r/[^\w\-\.]/, replacement)
    # Collapse multiple replacements
    |> String.replace(~r/#{replacement}+/, replacement)
  end

  defp maybe_downcase(name, true), do: String.downcase(name)
  defp maybe_downcase(name, false), do: name
end
