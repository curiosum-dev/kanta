defmodule KantaWeb.Translations.TranslationFormLive do
  use KantaWeb, :live_view

  alias Kanta.Translations
  alias KantaWeb.Translations.{DomainsTabBar, MessagesTable}

  def render(assigns) do
    ~H"""
    <div>
    </div>
    """
  end

  def mount(_params, _, socket) do
    {:ok, socket}
  end
end
