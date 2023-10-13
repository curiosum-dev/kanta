defmodule KantaWeb.Router do
  use Phoenix.Router

  # deps/phoenix/lib/phoenix/router.ex:2:no_return Function call/2 has no local return.
  @dialyzer {:no_return, {:call, 2}}

  defmacro kanta_dashboard(path \\ "/kanta", opts \\ []) do
    opts =
      if Macro.quoted_literal?(opts) do
        Macro.prewalk(opts, &expand_alias(&1, __CALLER__))
      else
        opts
      end

    scope =
      quote bind_quoted: binding() do
        scope path, alias: false, as: false do
          {session_name, session_opts, route_opts} = KantaWeb.Router.__options__(opts)

          import Phoenix.Router
          import Phoenix.LiveView.Router, only: [live: 4, live_session: 3]
          import Redirect

          live_session session_name, session_opts do
            get "/css-:md5", KantaWeb.Assets, :css, as: :kanta_dashboard_asset
            get "/js-:md5", KantaWeb.Assets, :js, as: :kanta_dashboard_asset

            redirect("/", "/kanta/dashboard", :permanent)

            scope "/", KantaWeb do
              scope "/dashboard", Dashboard do
                live "/", DashboardLive, :index, route_opts
              end

              scope "/contexts", Translations do
                live "/", ContextsLive, :index, route_opts
                live "/:id", ContextLive, :index, route_opts
              end

              scope "/domains", Translations do
                live "/", DomainsLive, :index, route_opts
                live "/:id", DomainLive, :index, route_opts
              end

              scope "/locales", Translations do
                live "/", LocalesLive, :index, route_opts

                scope "/:locale_id" do
                  scope "/translations" do
                    live "/", TranslationsLive, :index, route_opts
                    live "/:message_id", TranslationFormLive, :show, route_opts
                  end
                end
              end
            end
          end
        end
      end

    if Code.ensure_loaded?(Phoenix.VerifiedRoutes) do
      quote do
        unquote(scope)

        unless Module.get_attribute(__MODULE__, :kanta_dashboard_prefix) do
          @kanta_dashboard_prefix Phoenix.Router.scoped_path(__MODULE__, path)
          def __kanta_dashboard_prefix__, do: @kanta_dashboard_prefix
        end
      end
    else
      scope
    end
  end

  defmacro kanta_api(path \\ "/kanta-api") do
    quote bind_quoted: binding() do
      pipeline :kanta_api_pipeline do
        plug :accepts, ["json"]
        plug KantaWeb.APIAuthPlug
      end

      scope path, alias: false, as: false do
        scope "/", KantaWeb.Api do
          pipe_through :kanta_api_pipeline
          get "/", KantaApiController, :index

          resources "/contexts", ContextsController, only: [:index, :update]
          resources "/domains", DomainsController, only: [:index, :update]
          resources "/locales", LocalesController, only: [:index, :update]
          resources "/messages", MessagesController, only: [:index, :update]

          resources "/singular_translations", SingularTranslationsController,
            only: [:index, :update]

          resources "/plural_translations", PluralTranslationsController, only: [:index, :update]
        end
      end
    end
  end

  defp expand_alias({:__aliases__, _, _} = alias, env),
    do: Macro.expand(alias, %{env | function: {:kanta_dashboard, 2}})

  defp expand_alias(other, _env), do: other

  @doc false
  def __options__(options) do
    live_socket_path = Keyword.get(options, :live_socket_path, "/live")

    csp_nonce_assign_key =
      case options[:csp_nonce_assign_key] do
        nil -> nil
        key when is_atom(key) -> %{img: key, style: key, script: key}
        %{} = keys -> Map.take(keys, [:img, :style, :script])
      end

    on_mount = Keyword.get(options, :on_mount)

    session_args = [
      csp_nonce_assign_key
    ]

    {
      options[:live_session_name] || :kanta_dashboard,
      [
        session: {__MODULE__, :__session__, session_args},
        root_layout: {KantaWeb.LayoutView, :dashboard},
        on_mount: on_mount
      ],
      [
        private: %{live_socket_path: live_socket_path, csp_nonce_assign_key: csp_nonce_assign_key},
        as: :kanta_dashboard
      ]
    }
  end

  @doc false
  def __session__(
        conn,
        csp_nonce_assign_key
      ) do
    %{
      "csp_nonces" => %{
        img: conn.assigns[csp_nonce_assign_key[:img]],
        style: conn.assigns[csp_nonce_assign_key[:style]],
        script: conn.assigns[csp_nonce_assign_key[:script]]
      }
    }
  end
end
