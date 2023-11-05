defmodule MidtermProject.Swap.ExchangeRate do

  @enforce_keys [:from_currency, :to_currency, :rate]
  defstruct [:from_currency, :to_currency, :rate]

  def new(%{"5. Exchange Rate" => rate}, from_currency, to_currency) do
    %{
      from_currency: from_currency,
      to_currency: to_currency,
      rate: String.to_float(rate)
    }
  end
end
