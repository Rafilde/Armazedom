defmodule ArmazedomWeb.TransitionLive do
  use ArmazedomWeb, :live_view
  alias Armazedom.Repo

  def render(assigns) do
    ~H"""
    <div class="p-4 max-w-lg mx-auto">
      <h1 class="text-xl font-semibold mb-4">Adicionar <%= @tipo %></h1>

      <form phx-submit="salvar" class="space-y-4">
        <div>
          <label for="descricao" class="block text-sm font-medium text-zinc-900">Descrição</label>
          <input type="text" id="descricao" name="descricao" value={@descricao}
            phx-change="atualizar_descricao"
            class="block w-full rounded-lg border border-zinc-300 bg-white px-4 py-2 text-sm text-zinc-600 shadow-sm focus:border-blue-600 focus:ring-blue-600" required />
        </div>

        <div>
          <label for="periodo" class="block text-sm font-medium text-zinc-900">Periodo</label>
          <select name="period" id="period" class="block w-full rounded-lg border border-zinc-300 bg-white px-4 py-2 text-sm text-zinc-600 shadow-sm focus:border-blue-600 focus:ring-blue-600">
            <option value="mensal">Mensal</option>
            <option value="semanal">Semanal</option>
            <option value="anual">Anual</option>
            <option value="diario">Diário</option>
            <option value="quinzenal">Quinzenal</option>
          </select>
        </div>

        <div>
          <label for="valor" class="block text-sm font-medium text-zinc-900">Valor</label>
          <input type="number" step="0.01" id="valor" name="valor" value={@valor}
            phx-change="atualizar_valor"
            class="block w-full rounded-lg border border-zinc-300 bg-white px-4 py-2 text-sm text-zinc-600 shadow-sm focus:border-blue-600 focus:ring-blue-600" required />
        </div>

        <div>
          <label for="data" class="block text-sm font-medium text-zinc-900">Data</label>
          <input type="date" id="data" name="data"
            class="block w-full rounded-lg border border-zinc-300 bg-white px-4 py-2 text-sm text-zinc-600 shadow-sm focus:border-blue-600 focus:ring-blue-600" required />
        </div>

        <div class="flex justify-end mt-6">
          <button type="button" phx-click="cancelar" class="rounded-lg bg-gray-300 px-6 py-2 text-sm font-semibold text-zinc-900 shadow-md hover:bg-gray-300/90">
            Cancelar
          </button>
          <button type="submit" class="ml-4 rounded-lg bg-blue-600 px-6 py-2 text-sm font-semibold text-white shadow-md hover:bg-blue-600/90 focus:ring-2 focus:ring-blue-600">
            Salvar
          </button>
        </div>
      </form>
    </div>
    """
  end

  #def handle_params(params, session, socket) do
  #  user_id = session["user_id"]  # Acessando o user_id da sessão
  #  IO.inspect(user_id, label: "ID do Usuário da Sessão")

   # tipo = case params["tipo"] do
  #    "receita" -> "Receita"
  #    "despesa" -> "Despesa"
   #   _ -> "Transação"
   # end

  #  {:ok, assign(socket, tipo: tipo, descricao: "", valor: "", period: "mensal", data: "", user_id: user_id)}
 # end

 def mount(params, _session, socket) do
  tipo = case params["tipo"] do
    "receita" -> "Receita"
    "despesa" -> "Despesa"
    _ -> "Transação"
  end

  # Atribuindo valores ao socket
  {:ok, assign(socket, tipo: tipo, descricao: "", valor: "", period: "mensal", data: "", user_id: 1)}
end


  def handle_event("salvar", %{"descricao" => descricao, "valor" => valor, "period" => period}, socket) do
    # Criando a estrutura da receita com os dados do formulário
    changeset = Armazedom.Financials.Income.changeset(%Armazedom.Financials.Income{}, %{
      description: descricao,
      amount: Decimal.new(valor),
      period: period,
      user_id: socket.assigns.user_id  # Usando o ID do usuário logado
    })

    # Salvar a receita no banco de dados
    case Repo.insert(changeset) do
      {:ok, _income} ->
        {:noreply, push_navigate(socket, to: "/")}

      {:error, changeset} ->
        IO.inspect(changeset)
        {:noreply, assign(socket, error: "Erro ao salvar a receita")}
    end
  end


  def handle_event("atualizar_descricao", %{"descricao" => descricao}, socket) do
    {:noreply, assign(socket, descricao: descricao)}
  end

  def handle_event("atualizar_valor", %{"valor" => valor}, socket) do
    {:noreply, assign(socket, valor: valor)}
  end

  def handle_event("cancelar", _params, socket) do
    {:noreply, push_navigate(socket, to: "/")}
  end
end
