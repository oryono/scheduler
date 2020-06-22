defmodule Scheduler.Banking.Transactions.MonthlyCharge do
  def build(wallet_id, income_account_id, amount, auth_account_id, client_id) do
    description = "Monthly Charge"
    transaction_reference = generate_transaction_reference

    [
      {:debit, wallet_id, description, amount, transaction_reference, auth_account_id, client_id},
      {:credit, income_account_id, description, amount, transaction_reference, auth_account_id, client_id},
    ]
  end

  defp generate_transaction_reference do
    alphabet = Enum.to_list(?0..?9)
    length = 10

    Enum.take_random(alphabet, length) |> List.to_string
  end
end
