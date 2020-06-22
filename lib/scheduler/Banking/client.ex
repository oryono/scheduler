defmodule Scheduler.Banking.Client do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "clients" do
    field :address, :string
    field :name, :string
    field :phone, :string
    field :slug, :string

    has_many :bank_accounts, Scheduler.Banking.Account

    timestamps()
  end
end
