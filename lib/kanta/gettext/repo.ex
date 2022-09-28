defmodule Kanta.Gettext.Repo do
  @behaviour Gettext.Repo

  alias Kanta.Cache.Agent, as: CacheAgent
  alias Kanta.EmbeddedSchemas.SingularTranslation
  # alias Kanta.Storage

  @impl Gettext.Repo
  def init(_) do
    __MODULE__
  end

  @impl Gettext.Repo
  def get_translation(locale, domain, msgctxt, msgid, _) do
    with :not_found <-
           CacheAgent.get_cached_translation_text(%SingularTranslation{
             locale: locale,
             domain: domain,
             msgctxt: msgctxt,
             msgid: msgid
           }) do
      #        :not_found <- Storage.get_stored_translation(locale, domain, msgctxt, msgid) do
      :not_found
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
