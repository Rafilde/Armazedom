defmodule Armazedom.Repo do
  use Ecto.Repo,
    otp_app: :armazedom,
    adapter: Ecto.Adapters.Postgres
end
