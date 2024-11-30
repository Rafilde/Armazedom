defmodule Armazedom.Financials.Income do
  use Ecto.Schema
  import Ecto.Changeset

  schema "incomes" do
    field :description, :string
    field :period, :string
    field :amount, :decimal
    field :user_id, :id

    timestamps(type: :utc_datetime)  # O Ecto vai cuidar de inserted_at e updated_at
  end

  @doc false
  def changeset(income, attrs) do
    income
    |> cast(attrs, [:amount, :description, :period, :user_id])  # Não inclui :inserted_at nem :updated_at
    |> validate_required([:amount, :description, :period, :user_id])  # Não valida :inserted_at nem :updated_at
  end
end
