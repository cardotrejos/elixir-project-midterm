defmodule MidtermProject.Accounts.Wallet do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias MidtermProject.Accounts.{User, Wallet}
  alias MidtermProject.Config

  @currencies Config.currencies()
  @required_params [:currency, :cent_amount, :user_id]
  @transaction_types [:withdrawal, :deposit]

  schema "wallets" do
    field :cent_amount, :integer
    field :currency, Ecto.Enum, values: @currencies
    belongs_to :user, User

    timestamps()
  end

  def create_changeset(params) do
    changeset(%Wallet{}, params)
  end

  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, @required_params)
    |> validate_required(@required_params)
    |> unique_constraint([:currency, :user_id])
  end

  def by_user_id(query \\ Wallet, user_id) do
    where(query, [w], w.user_id == ^user_id)
  end

  def by_currency(query \\ Wallet, currency) do
    where(query, [w], w.currency == ^currency)
  end

  def by_user_id_and_currency(query \\ Wallet, user_id, currency) do
    query
    |> by_user_id(user_id)
    |> by_currency(currency)
  end

  def lock_for_update(query \\ Wallet) do
    lock(query, "FOR UPDATE")
  end

  def transaction_types do
    @transaction_types
  end
end
