defmodule Kanta.Translations.Messages do
  @moduledoc """
  Kanta Messages subcontext
  """

  alias Kanta.Repo

  alias Kanta.Translations.Message
  alias Kanta.Translations.{SingularTranslation, PluralTranslation}

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

  @doc """
  Returns the count of stale messages in the system.

  A message is considered "stale" if it doesn't exist in ANY locale's PO files.
  This reads from the cached state in MessagesExtractorAgent.

  ## Returns

    * Integer count of stale messages

  """
  def get_stale_messages_count do
    Kanta.POFiles.MessagesExtractorAgent.get_stale_message_ids()
    |> MapSet.size()
  end

  def create_message(attrs, opts \\ []) do
    %Message{} |> Message.changeset(attrs) |> Repo.get_repo().insert(opts)
  end

  def update_message(message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.get_repo().update()
  end

  @doc """
  Deletes a stale message and ALL its translations across ALL locales.

  This function removes the message completely from the system, including
  all singular and plural translations in every locale.

  ## Arguments

    * `message_id` - Integer ID of the message

  ## Returns

    * `{:ok, stats}` - Map containing deletion statistics:
      * `:translations_deleted` - Number of translations deleted across all locales
      * `:message_deleted` - Boolean indicating if message was deleted
    * `{:error, reason}` - If deletion fails

  ## Examples

      iex> Kanta.Translations.Messages.delete_stale_message(123)
      {:ok, %{translations_deleted: 5, message_deleted: true}}

  """
  def delete_stale_message(message_id) do
    import Ecto.Query

    # Delete all translations and message in a transaction
    Repo.get_repo().transaction(fn ->
      # Delete ALL singular translations for this message (all locales)
      {singular_count, _} =
        from(st in SingularTranslation,
          where: st.message_id == ^message_id
        )
        |> Repo.get_repo().delete_all()

      # Delete ALL plural translations for this message (all locales)
      {plural_count, _} =
        from(pt in PluralTranslation,
          where: pt.message_id == ^message_id
        )
        |> Repo.get_repo().delete_all()

      # Delete the message itself
      {message_count, _} =
        from(m in Message, where: m.id == ^message_id)
        |> Repo.get_repo().delete_all()

      %{
        translations_deleted: singular_count + plural_count,
        message_deleted: message_count == 1
      }
    end)
  end

  @doc """
  Deletes all stale messages and their translations from the database.

  This function reads stale message IDs from the MessagesExtractorAgent
  and deletes each stale message along with ALL their translations across ALL locales.

  ## Returns

    * `{:ok, stats}` - Map containing deletion statistics:
      * `:messages_deleted` - Number of messages deleted
      * `:translations_deleted` - Number of translations deleted
    * `{:error, reason}` - If deletion fails

  ## Examples

      iex> Kanta.Translations.Messages.delete_all_stale_messages()
      {:ok, %{messages_deleted: 3, translations_deleted: 12}}

  """
  def delete_all_stale_messages do
    stale_ids =
      Kanta.POFiles.MessagesExtractorAgent.get_stale_message_ids()
      |> MapSet.to_list()

    {total_messages, total_translations} =
      Enum.reduce(stale_ids, {0, 0}, fn message_id, {msg_count, trans_count} ->
        case delete_stale_message(message_id) do
          {:ok, stats} ->
            {
              msg_count + if(stats.message_deleted, do: 1, else: 0),
              trans_count + stats.translations_deleted
            }

          {:error, _reason} ->
            {msg_count, trans_count}
        end
      end)

    # Update the agent to clear stale IDs since we just deleted them
    Kanta.POFiles.MessagesExtractorAgent.update_stale_message_ids(MapSet.new())

    {:ok, %{messages_deleted: total_messages, translations_deleted: total_translations}}
  end
end
