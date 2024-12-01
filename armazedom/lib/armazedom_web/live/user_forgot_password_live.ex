defmodule ArmazedomWeb.UserForgotPasswordLive do
  use ArmazedomWeb, :live_view

  alias Armazedom.Accounts

  def render(assigns) do
    ~H"""
<div class="min-h-screen flex items-center justify-center">
  <div class="bg-white rounded-lg shadow-lg p-8 max-w-sm w-full">
    <!-- Header -->
    <div class="text-center mb-6">
      <h1 class="text-3xl font-bold text-blue-600">Esqueceu sua senha?</h1>
      <p class="text-sm text-gray-600 mt-2">
        Enviaremos um link para redefinir sua senha para o seu e-mail.
      </p>
    </div>

    <!-- Password Reset Form -->
    <.simple_form for={@form} id="reset_password_form" phx-submit="send_email">
      <!-- Email Input -->
      <div class="mb-4">
        <.input
          field={@form[:email]}
          type="email"
          label="Email"
          required
          class="block w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:outline-none"
        />
      </div>

      <!-- Submit Button -->
      <div>
        <.button
          phx-disable-with="Enviando..."
          class="w-full py-3 px-6 bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white font-semibold rounded-full shadow-lg transition duration-300 ease-in-out transform hover:scale-105"
        >
          Enviar instruções de redefinição <span aria-hidden="true">→</span>
        </.button>
      </div>
    </.simple_form>

    <!-- Footer -->
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

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/users/reset_password/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions to reset your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
