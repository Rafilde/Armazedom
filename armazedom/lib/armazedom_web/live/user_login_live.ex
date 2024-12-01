defmodule ArmazedomWeb.UserLoginLive do
  use ArmazedomWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex items-center justify-center">
      <div class="bg-white rounded-lg shadow-lg p-8 max-w-[400px] w-full">
        <!-- Header -->
        <div class="text-center mb-14">
          <h1 class="text-3xl font-bold text-blue-600 tracking-wide">Bem-vindo de volta!</h1>
          <p class="text-sm text-gray-400 mt-2 tracking-wider">
            Faça login para acessar sua conta e continuar.
          </p>
        </div>

        <!-- Login Form -->
        <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
          <!-- Email Input -->
          <div class="mb-4">
            <.input
              field={@form[:email]}
              type="email"
              placeholder="Informe seu e-mail"
              required
              class="block w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:outline-none"
            />
          </div>

          <!-- Password Input -->
          <div class="mb-4">
            <.input
              field={@form[:password]}
              type="password"
              placeholder="Informe sua senha"
              required
              class="block w-full px-4 py-2 bg-gray-50 border border-gray-400 rounded-md focus:ring-2 focus:ring-blue-300 focus:outline-none"
            />
          </div>

          <!-- Remember Me -->
          <div class="mb-4 flex items-center">
            <.input
              field={@form[:remember_me]}
              type="checkbox"
              label="Lembrar-me"
              class="text-sm text-gray-600"
            />
          </div>

          <!-- Forgot Password Link -->
          <div class="mb-4 text-right">
            <.link
              href={~p"/users/reset_password"}
              class="text-sm font-semibold text-blue-600 hover:underline"
            >
              Esqueceu sua senha?
            </.link>
          </div>

          <!-- Submit Button -->
          <div>
            <.button
              phx-disable-with="Entrando..."
              class="w-full py-3 px-6 bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white font-semibold rounded-full shadow-lg transition duration-300 ease-in-out transform hover:scale-105"
            >
              Entrar <span aria-hidden="true">→</span>
            </.button>
          </div>
        </.simple_form>

        <!-- Footer -->
        <div class="mt-6 text-center text-sm text-gray-600">
          Não tem uma conta?
          <.link
            navigate={~p"/users/register"}
            class="font-semibold text-blue-600 hover:underline"
          >
            Cadastre-se agora
          </.link>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
