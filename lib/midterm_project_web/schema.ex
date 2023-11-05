defmodule MidtermProjectWeb.Schema do
  @moduledoc false
  use Absinthe.Schema
  alias MidtermProjectWeb.Middlewares.HandleErrors

  import_types MidtermProjectWeb.Types.Currency
  import_types MidtermProjectWeb.Types.ExchangeRate
  import_types MidtermProjectWeb.Types.TotalWorth
  import_types MidtermProjectWeb.Types.TotalWorthChange
  import_types MidtermProjectWeb.Types.Transaction
  import_types MidtermProjectWeb.Types.User
  import_types MidtermProjectWeb.Types.Wallet
  import_types MidtermProjectWeb.Schema.Queries.ExchangeRate
  import_types MidtermProjectWeb.Schema.Queries.TotalWorth
  import_types MidtermProjectWeb.Schema.Queries.User
  import_types MidtermProjectWeb.Schema.Queries.Wallet
  import_types MidtermProjectWeb.Schema.Mutations.User
  import_types MidtermProjectWeb.Schema.Mutations.Wallet
  import_types MidtermProjectWeb.Schema.Subscriptions.ExchangeRate
  import_types MidtermProjectWeb.Schema.Subscriptions.TotalWorth
  import_types MidtermProjectWeb.Schema.Subscriptions.User

  query do
    import_fields :exchange_rate_queries
    import_fields :total_worth_queries
    import_fields :user_queries
    import_fields :wallet_queries
  end

  mutation do
    import_fields :user_mutations
    import_fields :wallet_mutations
  end

  subscription do
    import_fields :exchange_rate_subscriptions
    import_fields :total_worth_subscriptions
    import_fields :user_subscriptions
  end

  def context(ctx) do
    source = Dataloader.Ecto.new(MidtermProject.Repo)
    dataloader = Dataloader.add_source(Dataloader.new(), MidtermProject.Accounts, source)
    Map.put(ctx, :loader, dataloader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end

  def middleware(middleware, _, %{identifier: identifier})
      when identifier in [:query, :subscription, :mutation] do
    middleware ++ [HandleErrors]
  end

  def middleware(middleware, _, _) do
    middleware
  end
end
