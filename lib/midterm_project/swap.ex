defmodule MidtermProject.Swap do
  @moduledoc """
  Regularly queries the API for the exchange rates of
  all possible currency combinations
  """
  use Task, restart: :permanent
  require Logger

  alias MidtermProject.{Config, ExchangeRateStorage}
  alias MidtermProject.Swap.ExchangeRate

  @exchange_rate_getter Config.exchange_rate_getter()
  @cache_name :exchange_rate_cache

  def start_link({currency1, currency2}, cache_name \\ @cache_name) do
    Task.start_link(__MODULE__, :run, [currency1, currency2, cache_name])
  end

  def child_spec({currency1, currency2}) do
    %{
      id: name(currency1, currency2),
      start: {__MODULE__, :start_link, [{currency1, currency2}]}
    }
  end

  def run(from_currency, to_currency, cache_name) do
    case @exchange_rate_getter.query_api_and_decode_json_response(
           from_currency,
           to_currency
         ) do
      {:ok, data} ->
        exchange_rate = ExchangeRate.new(data, from_currency, to_currency)
        ExchangeRateStorage.store_exchange_rate(exchange_rate, cache_name)

        Absinthe.Subscription.publish(MidtermProjectWeb.Endpoint, exchange_rate,
          exchange_rate_updated: "exchange_rate_updated:all"
        )

        Absinthe.Subscription.publish(MidtermProjectWeb.Endpoint, exchange_rate,
          exchange_rate_updated: "exchange_rate_updated:#{from_currency}"
        )

      {:error, reason} ->
        Logger.error(
          "Exchange rate for #{from_currency} into #{to_currency} not received. Reason: #{inspect(reason)}"
        )
    end

    Process.sleep(:timer.seconds(1))
    run(from_currency, to_currency, cache_name)
  end


  defp name(currency1, currency2) do
    :"exchanger_#{currency1}_#{currency2}"
  end
end
