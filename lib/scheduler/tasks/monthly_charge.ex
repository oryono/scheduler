defmodule Mix.Tasks.MonthlyCharge do
    use Mix.Task
    import Ecto.Query

    @shortdoc "Charges an account for monthly charge."
    def run(_) do
        IO.puts "Running Monthly account charges"
        wallet_query = from ba in Scheduler.Banking.Account, where: ba.type == 'liability'
        clients = Scheduler.Banking.Client
                  |> Scheduler.Repo.all
                  |> Scheduler.Repo.preload(bank_accounts: :wallet_product)

        Enum.each(
            clients,
            fn client ->
                income_account = Scheduler.Repo.one(
                    from ba in Scheduler.Banking.Account,
                    where: ba.name == "Bank Charges" and ba.client_id == ^client.id
                )
                Enum.each(
                    client.bank_accounts,
                    fn account ->
                        cond do
                            account.type == "liability" ->
                                monthly_charge = cond do
                                    account.wallet_product -> account.wallet_product.monthly_charge
                                    true -> 0
                                end

                                Scheduler.Banking.Transactions.MonthlyCharge.build(
                                    account.id,
                                    income_account.id,
                                    monthly_charge,
                                    nil,
                                    client.id
                                )
                                |> Scheduler.Banking.write_entries

                            true -> false
                        end

                    end
                )
            end
        )
    end
end
