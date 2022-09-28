defmodule KantaWeb.TranslationLiveComponent do
  use KantaWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="form-group mb-2">
      <label><%= header(assigns) %></label>
      <div class="input-group">
        <input
          type="text"
          value={@translated}
          placeholder={@msgid}
          phx-keyup="keyup"
          phx-target={@myself}
          class="form-control"
        />
        <%= save_button(assigns) %>
      </div>
    </div>
    """
  end

  def mount(socket) do
    {:ok, assign(socket, :saved?, true)}
  end

  def handle_event("keyup", %{"key" => "Enter"}, socket) do
    handle_event("save", nil, socket)
  end

  def handle_event("keyup", %{"value" => translated}, socket) do
    {:noreply,
     socket
     |> assign(:translated, translated)
     |> assign(:saved?, false)}
  end

  def handle_event("save", _event, socket) do
    %{
      assigns: %{
        language: language,
        domain: domain,
        msgid: msgid,
        msgctxt: msgctxt,
        translated: translated
      }
    } = socket

    translated = String.trim(translated)
    Kanta.set_translation(language, domain, msgctxt, msgid, translated)

    {:noreply,
     socket
     |> assign(:translated, translated)
     |> assign(:saved?, true)}
  end

  defp header(%{msgctxt: nil, msgid: msgid}), do: "#{msgid}"

  defp header(assigns) do
    ~H"""
    <%= @msgid %>
    <span class="fst-italic text-muted">(context: <%= @msgctxt %>)</span>
    """
  end

  defp save_button(%{saved?: true} = assigns) do
    ~H"""
    <input
      type="button"
      class="btn btn-primary disabled"
      value="Saved"
      phx-click="save"
      phx-target={@myself}
    />
    """
  end

  defp save_button(%{saved?: false} = assigns) do
    ~H"""
    <input
      type="button"
      class="btn btn-primary"
      value="Save"
      phx-click="save"
      phx-target={@myself}
    />
    """
  end
end
