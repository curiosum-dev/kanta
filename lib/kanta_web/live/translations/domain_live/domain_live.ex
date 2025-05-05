defmodule KantaWeb.Translations.DomainLive do
  use KantaWeb, :live_view

  def mount(%{"id" => id}, session, socket) do
    data_access = session["data_access"]

    socket =
      case data_access.get_resource(:domain, id, []) do
        {:ok, domain} ->
          assign(socket, :domain, domain)

        {:error, _, _reason} ->
          socket
          |> put_flash(:error, "Domain not found")
          |> redirect(to: "/kanta/domains")
      end

    {:ok, socket}
  end
end
