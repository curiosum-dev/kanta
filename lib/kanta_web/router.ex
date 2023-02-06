defmodule KantaWeb.Router do
  use KantaWeb, :router

  scope "/", KantaWeb do
    get "/", PageController, :index

    scope "/locales", Translations do
      get "/", LocaleController, :index
    end

    scope "/translations", Translations do
      get "/", TranslationController, :index
      get "/:language", TranslationController, :show
    end

    scope "/admin", Admin do
      get "/storage", StorageController, :index
      get "/gettext", GettextController, :index
    end
  end
end
