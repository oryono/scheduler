defmodule Scheduler.Banking.WalletProduct do
  use Ecto.Schema
  import Ecto.Changeset

  schema "wallet_products" do
    field :client_id, :integer
    field :min_balance, :decimal
    field :monthly_charge, :decimal
    field :name, :string
    field :type, :string
    field :interest_rate, :decimal
    field :deposit_fee, :decimal
    field :withdrawal_fee, :decimal
    field :opening_balance, :decimal

    timestamps()
  end
end
