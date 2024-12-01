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

    # Calculando os valores necessários
    total_receitas =
      transactions
      |> Enum.filter(fn transaction -> transaction.type == "receita" end)
      |> Enum.map(& &1.amount)
      |> Enum.reduce(Decimal.new(0), &Decimal.add/2)

    total_despesas =
      transactions
      |> Enum.filter(fn transaction -> transaction.type == "despesa" end)
      |> Enum.map(& &1.amount)
      |> Enum.reduce(Decimal.new(0), &Decimal.add/2)

    saldo_total = Decimal.sub(total_receitas, total_despesas)

    # Atribuindo as variáveis para o template
    conn
    |> assign(:transactions, transactions)
    |> assign(:total_receitas, total_receitas)
    |> assign(:total_despesas, total_despesas)
    |> assign(:saldo_total, saldo_total)
    |> render(:home)
  end

  def dashboard(conn, _params) do
    # Renderizar a página do Dashboard
    render(conn, "dashboard.html")
  end

  def delete_transaction(conn, %{"id" => id}) do
    # Encontrar a transação pelo ID
    transaction = Repo.get(Transaction, id)

    # Excluir a transação se encontrada
    case transaction do
      nil ->
        conn
        |> put_flash(:error, "Transação não encontrada!")
        |> redirect(to: "/")

      _ ->
        Repo.delete(transaction)

        conn
        |> put_flash(:info, "Transação excluída com sucesso!")
        |> redirect(to: "/")
    end
  end

  def edit_transaction(conn, %{"id" => id}) do
    # Encontrar a transação com base no ID
    transaction = Repo.get(Transaction, id)

    # Se a transação não for encontrada, exibe uma mensagem de erro
    if transaction do
      # Criar o changeset para a transação
      changeset = Transaction.changeset(transaction, %{})

      # Renderiza o formulário de edição com o changeset
      render(conn, "edit_transaction.html", transaction: transaction, changeset: changeset)
    else
      conn
      |> put_flash(:error, "Transação não encontrada!")
      |> redirect(to: "/")
    end
  end


  def update_transaction(conn, %{"id" => id, "transaction" => transaction_params}) do
    # Converte as chaves do map para átomos
    transaction_params = Enum.map(transaction_params, fn {k, v} ->
      {String.to_atom(k), v}
    end)
    |> Enum.into(%{})

    transaction = Repo.get(Armazedom.Financials.Transaction, id)

    if transaction do
      changeset = Armazedom.Financials.Transaction.changeset(transaction, Map.put(transaction_params, :user_id, transaction.user_id))

      case Repo.update(changeset) do
        {:ok, _updated_transaction} ->
          conn
          |> put_flash(:info, "Transação atualizada com sucesso!")
          |> redirect(to: "/")

        {:error, changeset} ->
          render(conn, "edit_transaction.html", transaction: transaction, changeset: changeset)
      end
    else
      conn
      |> put_flash(:error, "Transação não encontrada!")
      |> redirect(to: "/")
    end
  end
end
