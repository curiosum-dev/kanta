defmodule Kanta.PoFiles.Services.ExtractMessage do
  @moduledoc """
  Service responsible for extracting gettext messages from .po files
  """

  alias Kanta.Repo

  alias Kanta.Translations
  alias Kanta.Translations.{Context, Domain}

  @default_domain "default"
  @default_context "default"

  def call(attrs) do
    Repo.get_repo().transaction(fn ->
      with {:ok, domain} <- assign_domain(attrs[:domain_name]),
           {:ok, context} <- assign_context(attrs[:context_name]),
           {:ok, message} <- get_or_create_message(attrs, context, domain) do
        message
      end
    end)
  end

  def default_domain, do: @default_domain
  def default_context, do: @default_context

  defp get_or_create_message(attrs, nil, nil) do
    case Translations.get_message(filter: [msgid: attrs[:msgid]]) do
      {:ok, message} -> {:ok, message}
      {:error, :message, :not_found} -> Translations.create_message(attrs)
    end
  end

  defp get_or_create_message(attrs, %Context{id: context_id}, %Domain{id: domain_id}) do
    case Translations.get_message(
           filter: [msgid: attrs[:msgid], context_id: context_id, domain_id: domain_id]
         ) do
      {:ok, message} ->
        {:ok, message}

      {:error, :message, :not_found} ->
        attrs
        |> Map.put(:context_id, context_id)
        |> Map.put(:domain_id, domain_id)
        |> Translations.create_message()
    end
  end

  defp get_or_create_message(attrs, %Context{id: context_id}, nil) do
    case Translations.get_message(filter: [msgid: attrs[:msgid], context_id: context_id]) do
      {:ok, message} ->
        {:ok, message}

      {:error, :message, :not_found} ->
        attrs
        |> Map.put(:context_id, context_id)
        |> Map.put(:domain_id, @default_domain)
        |> Translations.create_message()
    end
  end

  defp get_or_create_message(%{msgid: msgid} = attrs, nil, %Domain{id: domain_id}) do
    case Translations.get_message(filter: [msgid: msgid, domain_id: domain_id]) do
      {:ok, message} ->
        {:ok, message}

      {:error, :message, :not_found} ->
        attrs
        |> Map.put(:context_id, @default_context)
        |> Map.put(:domain_id, domain_id)
        |> Translations.create_message()
    end
  end

  defp assign_domain(nil), do: {:ok, nil}

  defp assign_domain(domain_name) do
    case Translations.get_domain(filter: [name: domain_name]) do
      {:ok, domain} ->
        {:ok, domain}

      {:error, :domain, :not_found} ->
        Translations.create_domain(%{
          name: domain_name
        })
    end
  end

  defp assign_context(nil), do: {:ok, nil}

  defp assign_context(context_name) do
    case Translations.get_context(filter: [name: context_name]) do
      {:ok, context} ->
        {:ok, context}

      {:error, :context, :not_found} ->
        Translations.create_context(%{
          name: context_name
        })
    end
  end
end
