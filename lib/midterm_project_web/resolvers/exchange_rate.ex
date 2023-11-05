defmodule MidtermProjectWeb.Resolvers.ExchangeRate do
  @moduledoc false
  alias MidtermProject.{Config}
  alias MidtermProject.{Swap.ExchangeRate, ExchangeRateStorage}

  @exchange_rate_cache Config.exchange_rate_cache()

  def get_exchange_rate(%{from_currency: from_currency, to_currency: from_currency}, _) do
    {:error,
     ErrorMessage.bad_request("Please enter two different currencies!", %{
       from_currency: from_currency,
       to_currency: from_currency
     })}
  end

  def get_exchange_rate(%{from_currency: from_currency, to_currency: to_currency}, _) do
    with {:ok, exchange_rate} <-
           ExchangeRateStorage.get_exchange_rate(from_currency, to_currency, @exchange_rate_cache) do
      {:ok,
       %ExchangeRate{from_currency: from_currency, to_currency: to_currency, rate: exchange_rate}}
    end
  end
end
