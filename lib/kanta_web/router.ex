defmodule KantaWeb.Router do
  use KantaWeb, :router

  scope "/", KantaWeb do
    get "/", PageController, :index

    scope "/locales", Translations do
      get "/", LocaleController, :index

      scope "/:locale_id" do
        scope "/translations" do
          get "/", TranslationController, :index
          get "/:message_id", TranslationController, :show
        end
      end
    end

    scope "/admin", Admin do
      get "/storage", StorageController, :index
      get "/gettext", GettextController, :index
    end
  end
end
