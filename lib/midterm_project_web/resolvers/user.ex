defmodule MidtermProjectWeb.Resolvers.User do
  @moduledoc false
  alias MidtermProject.{Accounts}

  def all(params, _) do
    {:ok, Accounts.all_users(params)}
  end

  def find(params, _) do
    Accounts.find_user(params)
  end

  def create_user(params, _) do
    Accounts.create_user(params)
  end

  def update_user(%{id: id} = params, _) do
    id
    |> String.to_integer()
    |> Accounts.update_user(Map.delete(params, :id))
  end
end
