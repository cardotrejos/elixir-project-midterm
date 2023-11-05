defmodule MidtermProject.Accounts do

  import Ecto.Query, warn: false

  alias MidtermProject.{
    Accounts.AccountsHelpers,
    Accounts.User,
    Accounts.Wallet,
    Repo
  }

  alias EctoShorts.Actions

  def all_users(params \\ %{}) do
    Actions.all(User, params)
  end

  def find_user(params) do
    Actions.find(User, params)
  end

  def create_user(params) do
    Actions.create(User, params)
  end

  def update_user(id, params) do
    Actions.find_and_update(User, %{id: id}, params)
  end

  def delete_user(%User{} = user) do
    Actions.delete(user)
  end

  def all_wallets(params \\ %{}) do
    Actions.all(Wallet, params)
  end

  def find_wallet(params) do
    Actions.find(Wallet, params)
  end

  def create_wallet(params) do
    Actions.create(Wallet, params)
  end

  def update_wallet(%Wallet{user_id: user_id, currency: currency}, params) do
    Actions.find_and_update(Wallet, %{user_id: user_id, currency: currency}, params)
  end

  def update_balance(%{user_id: user_id, currency: currency}, %{cent_amount: cent_amount}) do
    with {:ok, wallet} <- find_wallet(%{user_id: user_id, currency: currency}) do
      Actions.update(Wallet, wallet, %{cent_amount: wallet.cent_amount + cent_amount})
    end
  end

  def send_amount(%{
        from_user_id: from_user_id,
        from_currency: from_currency,
        cent_amount: cent_amount,
        to_user_id: to_user_id,
        to_currency: to_currency
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:from_user_id, from_user_id)
    |> Ecto.Multi.put(:from_currency, from_currency)
    |> Ecto.Multi.put(:to_user_id, to_user_id)
    |> Ecto.Multi.put(:to_currency, to_currency)
    |> Ecto.Multi.put(:cent_amount, cent_amount)
    |> Ecto.Multi.one(:find_from_wallet, &AccountsHelpers.find_and_lock_from_wallet/1)
    |> Ecto.Multi.one(:find_to_wallet, &AccountsHelpers.find_and_lock_to_wallet/1)
    |> Ecto.Multi.run(:check_wallets_found, &AccountsHelpers.check_wallets_found/2)
    |> Ecto.Multi.run(:exchange_rate, &AccountsHelpers.exchange_rate/2)
    |> Ecto.Multi.update(:update_from_wallet, &AccountsHelpers.update_from_wallet/1)
    |> Ecto.Multi.update(:update_to_wallet, &AccountsHelpers.update_to_wallet/1)
    |> Repo.transaction()
  end

  def delete_wallet(%Wallet{user_id: user_id, currency: currency}) do
    with {:ok, wallet} <- find_wallet(%{user_id: user_id, currency: currency}) do
      Actions.delete(wallet)
    end
  end

  def get_total_worth(%{user_id: user_id, currency: target_currency}) do
    case all_wallets(%{user_id: user_id}) do
      [] ->
        {:error,
         ErrorMessage.not_found("No wallets found for this User Id.", %{user_id: user_id})}

      wallets ->
        acc = {:ok, 0, target_currency}
        Enum.reduce_while(wallets, acc, &AccountsHelpers.reduce_wallets/2)
    end
  end
end
