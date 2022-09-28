defmodule KantaWeb.Router do
  use KantaWeb, :router
  alias KantaWeb.{PageController}
  alias KantaWeb.Languages.{TranslationsController}
  alias KantaWeb.Admin.{StorageController, GettextController}

  scope "/" do
    get "/", PageController, :index

    scope "/languages" do
      get "/", TranslationsController, :index
      get "/:language", TranslationsController, :show
    end

    scope "/admin" do
      get "/storage", StorageController, :index
      get "/gettext", GettextController, :index
    end
  end
end
