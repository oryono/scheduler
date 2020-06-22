defmodule Scheduler.Banking.Entry do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Scheduler.Banking

  @entry_types [:credit, :debit]


  schema "entries" do
    field :description, :string
    field :type, :string
    field :client_id, :integer
    field :amount, :decimal
    field :transaction_reference, :string
    field :auth_account_id, :integer
    field :running_balance, :decimal

    belongs_to :account, Scheduler.Banking.Account

    timestamps()
  end

  def from_tuple({type, account_id, description, amount, transaction_reference, auth_account_id, client_id})
      when type in @entry_types and is_binary(description) do
    account = Banking.get_account!(account_id)
    current_balance = Banking.account_balance(account)

    running_balance = case type do
      :credit ->
        case account.type do
          "liability" -> current_balance + Decimal.to_integer(Decimal.round(amount))
          "capital" -> current_balance + Decimal.to_integer(Decimal.round(amount))
          "asset" -> current_balance - Decimal.to_integer(Decimal.round(amount))
          "income" -> current_balance + Decimal.to_integer(Decimal.round(amount))
        end
      :debit ->
        case account.type do
          "liability" -> current_balance - Decimal.to_integer(Decimal.round(amount))
          "capital" -> current_balance - Decimal.to_integer(Decimal.round(amount))
          "asset" -> current_balance + Decimal.to_integer(Decimal.round(amount))
          "income" -> current_balance - Decimal.to_integer(Decimal.round(amount))
        end
    end
    %Scheduler.Banking.Entry{
      type: Atom.to_string(type),
      account_id: account_id,
      description: description,
      amount: amount,
      transaction_reference: transaction_reference,
      auth_account_id: auth_account_id,
      client_id: client_id,
      running_balance: running_balance
    }
  end
end
