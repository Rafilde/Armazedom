defmodule ArmazedomWeb.UserSessionController do
  use ArmazedomWeb, :controller

  alias Armazedom.Accounts
  alias ArmazedomWeb.UserAuth

  def create(conn, %{"_action" => "registered"} = params) do
    create(conn, params, "Conta criada com sucesso!")
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:user_return_to, ~p"/users/settings")
    |> create(params, "Senha atualizada com suceso!")
  end

  def create(conn, params) do
    create(conn, params, "Bem-vindo!")
  end

  defp create(conn, %{"user" => user_params}, info) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      IO.inspect(user.id, label: "ID do Usuário") #vendo o id do usuário
      conn
      # Armazenando o ID do usuário na sessão
      |> put_flash(:info, info)
      #|> put_session(:user_id, user.id)
      |> UserAuth.log_in_user(user, user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_flash(:error, "Email ou senha inválido")
      |> put_flash(:email, String.slice(email, 0, 160))
      |> redirect(to: ~p"/users/log_in")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Conta desconectada")
    |> UserAuth.log_out_user()
  end
end
