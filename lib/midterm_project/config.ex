defmodule MidtermProject.Config do
  @moduledoc """
  Fetches the environmental variables from the config.exs file
  """
  @app :midterm_project

  def currencies do
    Application.fetch_env!(@app, :currencies)
  end

  def exchange_rate_server do
    Application.fetch_env!(@app, :exchange_rate_server)
  end

  def exchange_rate_getter do
    Application.fetch_env!(@app, :exchange_rate_getter)
  end

  def global_ttl do
    Application.fetch_env!(@app, :global_ttl)
  end

  def ttl_check_interval do
    Application.fetch_env!(@app, :ttl_check_interval)
  end

  def exchange_rate_cache do
    Application.fetch_env!(@app, :exchange_rate_cache)
  end

  def env do
    Application.fetch_env!(@app, :env)
  end
end
