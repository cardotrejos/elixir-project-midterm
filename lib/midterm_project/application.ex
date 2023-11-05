defmodule MidtermProject.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias MidtermProject.Config

  @currencies Config.currencies()
  @global_ttl Config.global_ttl()
  @ttl_check_interval Config.ttl_check_interval()

  @impl true
  def start(_type, _args) do
    children =
      [
        MidtermProject.Repo,
        MidtermProjectWeb.Telemetry,
        {Phoenix.PubSub, name: :midterm_project},
        MidtermProjectWeb.Endpoint,
        {Absinthe.Subscription, MidtermProjectWeb.Endpoint},


        # Start the exchange rate cache
        {ConCache,
         [
           name: :exchange_rate_cache,
           global_ttl: @global_ttl,
           ttl_check_interval: @ttl_check_interval,
           touch_on_read: false
         ]}
        # Start the tasks that fetch the exchange rates and store them in the cache
      ] ++ exchangers()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MidtermProject.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MidtermProjectWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def exchangers do
    for currency1 <- @currencies,
        currency2 <- @currencies,
        currency2 !== currency1 do
      MidtermProject.Swap.child_spec({currency1, currency2})
    end
  end
end
