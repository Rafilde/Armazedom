defmodule Armazedom.Financials.Income do
  use Ecto.Schema
  import Ecto.Changeset

  schema "incomes" do
    field :description, :string
    field :period, :string
    field :amount, :decimal
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(income, attrs) do
    income
    |> cast(attrs, [:amount, :description, :period, :inserted_at, :updated_at])
    |> validate_required([:amount, :description, :period, :inserted_at, :updated_at])
  end
end
