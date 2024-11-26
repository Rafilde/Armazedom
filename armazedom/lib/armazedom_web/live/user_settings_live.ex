defmodule ArmazedomWeb.UserSettingsLive do
  use ArmazedomWeb, :live_view

  alias Armazedom.Accounts

  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex items-center justify-center bg-gray-50">
      <div class="bg-white rounded-lg shadow-lg p-8 max-w-lg w-full">
        <!-- Header -->
        <div class="text-center mb-6">
          <h1 class="text-2xl font-bold text-blue-600">Configurações da Conta</h1>
          <p class="text-sm text-gray-600 mt-2">
            Gerencie seu endereço de e-mail e configurações de senha
          </p>
        </div>

        <!-- Email Settings Form -->
        <div class="space-y-12 divide-y">
          <div>
            <.simple_form
              for={@email_form}
              id="email_form"
              phx-submit="update_email"
              phx-change="validate_email"
            >
              <div class="mb-4">
                <.input
                  field={@email_form[:email]}
                  type="email"
                  label="Email"
                  required
                  class="block w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:outline-none"
                />
              </div>

              <div class="mb-4">
                <.input
                  field={@email_form[:current_password]}
                  name="current_password"
                  id="current_password_for_email"
                  type="password"
                  label="Senha atual"
                  value={@email_form_current_password}
                  required
                  class="block w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:outline-none"
                />
              </div>

              <:actions>
                <div>
                  <.button phx-disable-with="Alterando..."
                    class="w-full py-3 px-6 bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white font-semibold rounded-full shadow-lg transition duration-300 ease-in-out transform hover:scale-105">
                    Alterar e-mail
                  </.button>
                </div>
              </:actions>
            </.simple_form>
          </div>

          <!-- Password Settings Form -->
          <div>
            <.simple_form
              for={@password_form}
              id="password_form"
              action={~p"/users/log_in?_action=password_updated"}
              method="post"
              phx-change="validate_password"
              phx-submit="update_password"
              phx-trigger-action={@trigger_submit}
            >
              <input
                name={@password_form[:email].name}
                type="hidden"
                id="hidden_user_email"
                value={@current_email}
              />
              <div class="mb-4">
                <.input
                  field={@password_form[:password]}
                  type="password"
                  label="Nova senha"
                  required
                  class="block w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:outline-none"
                />
              </div>
              <div class="mb-4">
                <.input
                  field={@password_form[:password_confirmation]}
                  type="password"
                  label="Confirmar nova senha"
                  class="block w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:outline-none"
                />
              </div>
              <div class="mb-4">
                <.input
                  field={@password_form[:current_password]}
                  name="current_password"
                  type="password"
                  label="Senha atual"
                  id="current_password_for_password"
                  value={@current_password}
                  required
                  class="block w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:outline-none"
                />
              </div>

              <:actions>
                <div>
                  <.button phx-disable-with="Alterando..."
                    class="w-full py-3 px-6 bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white font-semibold rounded-full shadow-lg transition duration-300 ease-in-out transform hover:scale-105">
                    Alterar senha
                  </.button>
                </div>
              </:actions>
            </.simple_form>
          </div>
        </div>

        <!-- Footer Links -->
        <div class="mt-6 text-center text-sm text-gray-600">
          <.link
            href={~p"/users/register"}
            class="font-semibold text-blue-600 hover:underline"
          >
            Cadastre-se agora
          </.link>
          |
          <.link
            href={~p"/users/log_in"}
            class="font-semibold text-blue-600 hover:underline"
          >
            Entrar
          </.link>
        </div>
      </div>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email alterado com sucesso.")

        :error ->
          put_flash(socket, :error, "O link de alteração de e-mail é inválido ou expirou.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "Um link para confirmar a alteração do e-mail foi enviado para o novo endereço."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end
end
