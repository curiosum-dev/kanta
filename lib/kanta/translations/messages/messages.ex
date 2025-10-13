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

      iex> Kanta.Translations.Messages.delete_message(123)
      {:ok, %{translations_deleted: 5, message_deleted: true}}

  """
  def delete_message(message_id) do
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

  def delete_messages(message_ids) when is_list(message_ids) do
    {total_messages, total_translations} =
      Enum.reduce(message_ids, {0, 0}, fn message_id, {msg_count, trans_count} ->
        case delete_message(message_id) do
          {:ok, stats} ->
            {
              msg_count + if(stats.message_deleted, do: 1, else: 0),
              trans_count + stats.translations_deleted
            }

          {:error, _reason} ->
            {msg_count, trans_count}
        end
      end)

    {:ok, %{messages_deleted: total_messages, translations_deleted: total_translations}}
  end

  @doc """
  Merges two messages by moving all translations from one message to another.

  This operation:
  1. Deletes all existing translations from the target message
  2. Moves all translations from the source message to the target message
  3. Deletes the source message

  This is useful when a stale message needs to be merged with its replacement
  (e.g., when msgid changes due to typo fixes or wording changes).

  ## Arguments

    * `from_message_id` - ID of the source message (will be deleted)
    * `to_message_id` - ID of the target message (will receive translations)

  ## Returns

    * `{:ok, target_message}` - Target message with merged translations
    * `{:error, :not_found}` - One or both messages not found
    * `{:error, reason}` - Merge failed

  ## Examples

      iex> merge_messages(123, 456)
      {:ok, %Message{id: 456, ...}}

  """
  def merge_messages(from_message_id, to_message_id) do
    import Ecto.Query

    with {:ok, from_message} <- get_message(filter: [id: from_message_id]),
         {:ok, to_message} <- get_message(filter: [id: to_message_id]) do
      # Perform merge in transaction
      Repo.get_repo().transaction(fn ->
        # Delete all translations from target message
        Repo.get_repo().delete_all(
          from st in SingularTranslation,
            where: st.message_id == ^to_message.id
        )

        Repo.get_repo().delete_all(
          from pt in PluralTranslation,
            where: pt.message_id == ^to_message.id
        )

        # Move all singular translations from source to target
        from(st in SingularTranslation,
          where: st.message_id == ^from_message.id
        )
        |> Repo.get_repo().update_all(set: [message_id: to_message.id])

        # Move all plural translations from source to target
        from(pt in PluralTranslation,
          where: pt.message_id == ^from_message.id
        )
        |> Repo.get_repo().update_all(set: [message_id: to_message.id])

        # Delete the source message
        Repo.get_repo().delete(from_message)

        # Invalidate cache
        Kanta.Cache.delete_all()

        # Return the target message
        to_message
      end)
    end
  end
end
