defmodule KantaWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use KantaWeb, :controller
      use KantaWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def static_paths do
    ~w(assets fonts images favicon.ico robots.txt)
  end

  def html do
    quote do
      @moduledoc false
      use Phoenix.Component

      unquote(view_helpers())
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, namespace: KantaWeb

      import Plug.Conn
      alias KantaWeb.Router.Helpers, as: Routes
      unquote(verified_routes())
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/kanta_web/templates",
        namespace: KantaWeb

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView

      unquote(view_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(view_helpers())
    end
  end

  def component do
    quote do
      use Phoenix.Component

      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  defp view_helpers do
    quote do
      @endpoint Application.compile_env(:kanta, :endpoint)

      import Phoenix.HTML
      import Phoenix.HTML.Form
      use PhoenixHTMLHelpers

      # Import LiveView and .heex helpers (live_render, live_patch, <.form>, etc)
      import Phoenix.Component

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import Kanta.Utils.ModuleUtils

      alias KantaWeb.Components.Icons
      alias KantaWeb.Router.Helpers, as: Routes
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: Application.compile_env(:kanta, :endpoint),
        router: KantaWeb.Router,
        statics: KantaWeb.static_paths()

      def dashboard_path(%Phoenix.LiveView.Socket{} = socket),
        do: socket.router.__kanta_dashboard_prefix__()

      def dashboard_path(%Plug.Conn{} = conn),
        do: conn.private.phoenix_router.__kanta_dashboard_prefix__()

      def dashboard_path(%Phoenix.LiveView.Socket{} = socket, "/" <> path),
        do: dashboard_path(socket, path)

      def dashboard_path(%Phoenix.LiveView.Socket{} = socket, path) do
        unverified_path(
          socket,
          Kanta.Router,
          socket.router.__kanta_dashboard_prefix__() <> "/" <> path
        )
      end

      def dashboard_path(%Plug.Conn{} = conn, "/" <> path), do: dashboard_path(conn, path)

      def dashboard_path(%Plug.Conn{} = conn, path) do
        unverified_path(
          conn,
          Kanta.Router,
          conn.private.phoenix_router.__kanta_dashboard_prefix__() <> "/" <> path
        )
      end
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
