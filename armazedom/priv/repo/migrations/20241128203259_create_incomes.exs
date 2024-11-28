defmodule Armazedom.Repo.Migrations.CreateIncomes do
  use Ecto.Migration

  def change do
    create table(:incomes) do
      add :amount, :decimal
      add :description, :string
      add :period, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:incomes, [:user_id])
  end
end
