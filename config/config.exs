# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :midterm_project,
  ecto_repos: [MidtermProject.Repo]

config :ecto_shorts,
  repo: MidtermProject.Repo,
  error_module: EctoShorts.Actions.Error

# Configures the endpoint
config :midterm_project, MidtermProjectWeb.Endpoint,
  pubsub_server: :midterm_project,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: MidtermProjectWeb.ErrorJSON],
    layout: false
  ],
  live_view: [signing_salt: "pUm+Qucc"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :midterm_project, MidtermProject.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

api_key = System.get_env("AC80IOTNTR50GANS")

config :midterm_project,
  load_from_system_env: true

config :midterm_project,
  exchange_rate_server: "localhost:4001/query",
  currencies: [:CAD, :USD, :EUR],
  exchange_rate_getter: MidtermProject.Swap.ExchangeRateGetter,
  global_ttl: 3_000,
  ttl_check_interval: 1_000,
  exchange_rate_cache: :exchange_rate_cache

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
