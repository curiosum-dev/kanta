defmodule KantaWeb.LayoutView do
  @moduledoc false
  use KantaWeb, :html

  embed_templates "../templates/layouts/*"

  def render(_, assigns), do: dashboard(assigns)

  def csp_nonce(conn, type) when type in [:script, :style, :img] do
    csp_nonce_assign_key = conn.private.csp_nonce_assign_key[type]
    conn.assigns[csp_nonce_assign_key]
  end

  def live_socket_path(conn) do
    [Enum.map(conn.script_name, &["/" | &1]) | conn.private.live_socket_path]
  end

  # TODO: Remove this and the conditional on Phoenix v1.7+
  @compile {:no_warn_undefined, Phoenix.VerifiedRoutes}

  def asset_path(conn, asset) when asset in [:css, :js] do
    hash = KantaWeb.Assets.current_hash(asset)

    if function_exported?(conn.private.phoenix_router, :__kanta_dashboard_prefix__, 0) do
      prefix = conn.private.phoenix_router.__kanta_dashboard_prefix__()

      Phoenix.VerifiedRoutes.unverified_path(
        conn,
        conn.private.phoenix_router,
        "#{prefix}/#{asset}-#{hash}"
      )
    else
      apply(
        conn.private.phoenix_router.__helpers__(),
        :kanta_dashboard_asset_path,
        [conn, asset, hash]
      )
    end
  end
end
