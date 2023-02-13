defmodule Kanta.Gettext.Repo do
  @behaviour Gettext.Repo

  alias Kanta.Translations.SingularTranslation
  alias Kanta.Translations

  @impl Gettext.Repo
  def init(_) do
    __MODULE__
  end

  @impl Gettext.Repo
  def get_translation(locale, domain, msgctxt, msgid, _) do
    with {:ok, %SingularTranslation{text: text}} <-
           Translations.get_singular_translation(%{
             "locale" => locale,
             "domain" => domain,
             "msgctxt" => msgctxt,
             "msgid" => msgid
           }) do
      {:ok, text}
    else
      _ -> :not_found
    end
  end

  @impl Gettext.Repo
  def get_plural_translation(
        _locale,
        _domain,
        _msgctxt,
        _msgid,
        _msgid_plural,
        _plural_form,
        _
      ) do
    :not_found
  end
end
