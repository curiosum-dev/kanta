defmodule KantaWeb.Components.Shared.Select do
  @moduledoc """
  Shared select component
  """

  use KantaWeb, :live_component

  alias KantaWeb.Components.Icons

  def update(assigns, socket) do
    %{field: field, options: options} = assigns

    selected_option =
      if is_nil(assigns[:selected_option]) do
        if is_nil(field) do
          List.first(options)
        else
          Enum.find(options, &(&1.value == value_to_integer(field.value))) || List.first(options)
        end
      else
        assigns.selected_option
      end

    {
      :ok,
      socket
      |> assign(:selected_option, selected_option)
      |> assign(assigns)
    }
  end

  def handle_event("update", %{"selectedIdx" => idx, "id" => id}, socket) do
    selected_option = Enum.at(socket.assigns.options, idx)

    {
      :noreply,
      socket
      |> push_event("close-selected", %{id: id, value: selected_option.value})
      |> assign(:selected_option, selected_option)
    }
  end

  defp value_to_integer(nil), do: nil
  defp value_to_integer(""), do: nil

  defp value_to_integer(value) do
    try do
      String.to_integer(value)
    catch
      _ -> nil
    end
  end
end
