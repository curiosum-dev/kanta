defmodule Kanta.Translations.Messages do
  @moduledoc """
  Kanta Messages subcontext
  """

  alias Kanta.Repo

  alias Kanta.Translations.Message

  alias Kanta.Translations.Messages.Finders.{GetMessage, ListAllMessages, ListMessages}

  def list_messages(params \\ []) do
    ListMessages.find(params)
  end

  def list_all_messages(params \\ []) do
    ListAllMessages.find(params)
  end

  def get_message(params \\ []) do
    GetMessage.find(params)
  end

  def get_messages_count do
    Repo.get_repo().aggregate(Message, :count)
  end

  def create_message(attrs, opts \\ []) do
    %Message{} |> Message.changeset(attrs) |> Repo.get_repo().insert(opts)
  end

  def update_message(message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.get_repo().update()
  end
end
