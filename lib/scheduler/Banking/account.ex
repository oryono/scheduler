defmodule Scheduler.Banking.Account do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "bank_accounts" do
    field :name, :string
    field :type, :string
    field :account_number, :string
    field :description, :string

    belongs_to :wallet_product, Scheduler.Banking.WalletProduct
    belongs_to :client, Scheduler.Banking.Client

    timestamps()
  end
end
