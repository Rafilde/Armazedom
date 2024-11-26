defmodule ArmazedomWeb.UserRegistrationLive do
  use ArmazedomWeb, :live_view

  alias Armazedom.Accounts
  alias Armazedom.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-2xl bg-white p-8 rounded-lg shadow-lg">
      <.flash_group flash={@flash} />

      <.header class="text-center">
        <h1 class="text-2xl font-bold text-blue-600">Registrar uma conta</h1>
        <:subtitle>
          Já tem uma conta?
          <.link navigate={~p"/users/log_in"} class="font-semibold text-blue-600 hover:underline">
            Faça login
          </.link>
          na sua conta agora.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=registered"}
        method="post"
      >
        <.error :if={@check_errors}>
          Oops, algo deu errado! Por favor, verifique os erros abaixo.
        </.error>

        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Senha" required />

        <:actions>
          <div class="w-full">
            <.button
              phx-disable-with="Criando conta..."
              class="w-full py-3 px-6 bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white font-semibold rounded-full shadow-lg transition duration-300 ease-in-out transform hover:scale-105"
            >
              Criar uma conta <span aria-hidden="true">→</span>
            </.button>
          </div>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
