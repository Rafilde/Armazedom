defmodule ArmazedomWeb.Router do
  use ArmazedomWeb, :router

  import ArmazedomWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ArmazedomWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :redirect_if_not_authenticated do
    plug :redirect_unauthenticated_to_login
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  defp redirect_unauthenticated_to_login(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> Phoenix.Controller.redirect(to: "/users/log_in")
      |> halt()
    end
  end

  scope "/", ArmazedomWeb do
    pipe_through [:browser, :redirect_if_not_authenticated]

    get "/", PageController, :home
  end

  scope "/", ArmazedomWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{ArmazedomWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", ArmazedomWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{ArmazedomWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", ArmazedomWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{ArmazedomWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  scope "/users/:user_id", ArmazedomWeb do
    pipe_through [:browser, :redirect_if_not_authenticated]

    live "/add/transactions", TransitionLive, :add_transaction
  end

  scope "/", ArmazedomWeb do
    pipe_through :browser

    get "/", PageController, :home
    delete "/transactions/:id", PageController, :delete_transaction
    get "/transactions/:id/edit", PageController, :edit_transaction 
    put "/transactions/update/:id", PageController, :update_transaction
  end

  scope "/", ArmazedomWeb do
    pipe_through [:browser, :redirect_if_not_authenticated]
  end
end
