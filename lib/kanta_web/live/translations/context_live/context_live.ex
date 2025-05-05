defmodule KantaWeb.Translations.ContextLive do
  use KantaWeb, :live_view

  def mount(%{"id" => id}, session, socket) do
    data_access = session["data_access"]

    socket =
      case data_access.get_resource(:context, id, []) do
        {:ok, context} ->
          assign(socket, :context, context)

        {:error, _, _reason} ->
          socket
          |> put_flash(:error, "Context not found")
          # TODO Error on redirect path
          |> redirect(to: dashboard_path(socket, "/contexts"))
      end

    {:ok, socket}
  end
end
