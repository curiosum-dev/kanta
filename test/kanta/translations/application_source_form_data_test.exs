defmodule Kanta.Translations.ApplicationSourceFormDataTest do
  use ExUnit.Case, async: true

  alias Kanta.Translations.ApplicationSource

  describe "to_form/1 on an Ecto.Changeset" do
    test "resolves via the Phoenix.HTML.FormData protocol (requires phoenix_ecto)" do
      changeset = Ecto.Changeset.change(%ApplicationSource{})

      # KantaWeb.Translations.ApplicationSourceFormLive.mount/3 calls
      # `to_form(Translations.change_application_source(...))`, which dispatches
      # through this exact protocol. Without :phoenix_ecto as a dependency, no
      # implementation exists for Ecto.Changeset and this raises
      # Protocol.UndefinedError.
      assert %Phoenix.HTML.Form{} = Phoenix.Component.to_form(changeset)
    end
  end
end
