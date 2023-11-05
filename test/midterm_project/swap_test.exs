defmodule MidtermProject.SwapTest do
  use ExUnit.Case

  alias MidtermProject.{Swap, ExchangeRateStorage}

  @currencies {:money1, :money2}

  setup do
    start_supervised!({ConCache, name: :test_cache, ttl_check_interval: 20, global_ttl: 3_000})
    Swap.start_link(@currencies, :test_cache)
    :ok
  end

  describe "run/2" do
    test "retrieves an exchange rate and stores it in the Exchange Rate Storage" do
      Process.sleep(50)
      assert {:ok, 1.11} === ExchangeRateStorage.get_exchange_rate(:money1, :money2, :test_cache)
    end
  end
end
