defmodule Kanta.Translations.Messages.Finders.ListMessagesJsonEncodingTest do
  use Kanta.Test.DataCase, async: false

  alias Kanta.Translations
  alias Kanta.Translations.Messages.Finders.ListMessages

  # Message's `@derive Jason.Encoder` includes :domain, :context,
  # :singular_translations and :plural_translations. Encoding a message
  # whose associations weren't preloaded raises, because
  # %Ecto.Association.NotLoaded{} isn't JSON-encodable. This mirrors what
  # KantaWeb.Api.MessagesController.index/2 does with the result of
  # ListMessages.find/1.
  describe "encoding the result of ListMessages.find/1" do
    setup do
      {:ok, domain} = Translations.create_domain(%{name: "default"})
      {:ok, context} = Translations.create_context(%{name: "ui"})

      {:ok, message} =
        Translations.create_message(%{
          msgid: "Hello world",
          message_type: :singular,
          domain_id: domain.id,
          context_id: context.id
        })

      %{message: message}
    end

    test "raises when the associations aren't preloaded", %{message: _message} do
      result = ListMessages.find(page: 1)

      assert_raise RuntimeError, ~r/association :domain .* was not loaded/, fn ->
        Jason.encode!(result)
      end
    end

    test "succeeds when domain/context/translations are preloaded", %{message: message} do
      result =
        ListMessages.find(
          page: 1,
          preloads: [:domain, :context, :singular_translations, :plural_translations]
        )

      assert {:ok, json} = Jason.encode(result)
      assert json =~ message.msgid
    end
  end
end
