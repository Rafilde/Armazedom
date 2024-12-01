defmodule ArmazedomWeb.PageController do
  use ArmazedomWeb, :controller

  alias Armazedom.Financials.Transaction
  alias Armazedom.Repo
  import Ecto.Query  # Importando Ecto.Query para usar a função `from/2`

  def home(conn, _params) do
    # Buscando todas as transações (transactions) do usuário atual
    user_id = conn.assigns[:current_user].id

    # Realizando a consulta no banco de dados usando o operador ^ para capturar o valor de user_id
    transactions = Repo.all(from t in Transaction, where: t.user_id == ^user_id)

    # Passando as transações para o template
    render(conn, :home, transactions: transactions)
  end
end
