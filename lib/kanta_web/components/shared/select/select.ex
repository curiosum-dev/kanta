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
          Enum.find(options, &(parse_select_value(&1.value) == field.value)) ||
            List.first(options)
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

  defp parse_select_value(nil), do: nil
  defp parse_select_value(""), do: nil
  defp parse_select_value(value), do: to_string(value)
end
