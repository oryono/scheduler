defmodule Scheduler.Banking do
  alias Scheduler.Repo
  alias Scheduler.Banking.Entry
  alias Scheduler.Banking.Account

  import Ecto.Query

  def account_balance(%Account{id: id, type: type}) do
    q = from t in Scheduler.Banking.Entry,
             select: fragment("SUM(CASE WHEN e0.type = 'credit' THEN (e0.amount) ELSE -(e0.amount) END)"),
             where: t.account_id == ^id

    balance = Repo.one(q) || Decimal.new(0)
    do_balance(Decimal.to_integer(Decimal.round(balance)), type)
  end

  defp do_balance(balance, "liability"), do: +balance
  defp do_balance(balance, "capital"), do: +balance
  defp do_balance(balance, "income"), do: +balance
  defp do_balance(balance, "asset"), do: -balance
  defp do_balance(balance, "expense"), do: -balance

  def write_entries(entries) do
    Repo.transaction(
      fn ->
        with {:ok, persisted_entries} <- insert_entries(entries),
             :ok <- credits_equal_debits(),
             :ok <- sufficient_funds(persisted_entries) do
          persisted_entries
        else
          {:error, reason} ->
            Repo.rollback(reason)
        end
      end
    )
  end

  defp insert_entries(entries) do
    entries =
      Enum.map(
        entries,
        fn tuple ->
          Entry.from_tuple(tuple)
          |> Repo.insert!
        end
      )

    entries = entries
              |> Repo.preload(:account)
    {:ok, entries}
  end

  defp credits_equal_debits do
    query = from e in Scheduler.Banking.Entry, select: fragment("SUM(e0.amount)")
    credits = Repo.all(from u in query, where: u.type == "credit")
    debits = Repo.all(from u in query, where: u.type == "debit")

    if credits == debits do
      :ok
    else
      {:error, :credits_not_equal_debits}
    end
  end

  defp sufficient_funds(entries) do
    accounts = Enum.map(entries, & &1.account)
    if Enum.all?(accounts, fn account -> account_balance(account) >= 0 end) do
      :ok
    else
      {:error, :insufficient_funds}
    end
  end

  def get_account!(id) do
    Repo.get!(Account, id)
  end
end