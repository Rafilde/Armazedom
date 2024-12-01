defmodule Armazedom.Financials.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :type, :string
    field :description, :string
    field :period, :integer
    field :amount, :decimal
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:type, :amount, :description, :period, :user_id])
    |> validate_required([:type, :amount, :description, :period, :user_id])
  end
end
