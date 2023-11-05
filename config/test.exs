import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :midterm_project, MidtermProject.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "midterm_project_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :midterm_project, MidtermProjectWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "HY03CbcCOF3Qd2OqWFsxc3+zNMgX7fClP26BKVk3xJQ+7iQvt3JLwttXeO5Q+tK+",
  server: false

# In test we don't send emails.
config :midterm_project, MidtermProject.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :midterm_project,
  exchange_rate_getter: MidtermProject.ExchangeRateGetterStub,
  global_ttl: 50,
  ttl_check_interval: 10,
  exchange_rate_cache: :test_cache,
  env: :test
