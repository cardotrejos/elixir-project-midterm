defmodule MidtermProjectWeb.Resolvers.TotalWorth do
  @moduledoc false
  alias MidtermProject.{Accounts}

  def get_total_worth(%{user_id: user_id, currency: target_currency}, _) do
    with {:ok, net_worth, _} <-
           Accounts.get_total_worth(%{user_id: user_id, currency: target_currency}) do
      {:ok, %{user_id: user_id, currency: target_currency, cent_amount: net_worth}}
    end
  end
end
