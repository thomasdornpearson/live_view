defmodule LiveViewWeb.Router do
  use LiveViewWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LiveViewWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug LiveViewWeb.Plug.AuthenticateJwt
  end

  pipeline :authenicated_express do
    plug LiveViewWeb.Plug.AuthenticateExpress
  end

  scope "/phoenix/", LiveViewWeb do
    pipe_through :browser

    live "/", TodoLive, :index
  end

  scope "/phoenix/api", LiveViewWeb do
    pipe_through [:api, :authenticated]
    get "/test", RestController, :get_file
    post "/test", RestController, :get_file
    post "/uploadfile", RestController, :upload_file
    get "/users", RestController, :get_user_list
    get "/categories", RestController, :get_categories
    get "/users/:test", RestController, :get_user_list
  end


  scope "/phoenix/api", LiveViewWeb do
    pipe_through [:api, :authenicated_express]
    post "/senduploaddata", RestController, :send_upload_data
  end

  # Other scopes may use custom stacks.
  # scope "/api", LiveViewTodosWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/phoenix" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: LiveViewWeb.Telemetry, live_socket_path: "/phoenix/live"
    end
  end
end
