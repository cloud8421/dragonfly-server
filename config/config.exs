# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :logger, :console,
  level: :error

config :processor,
  job_worker_timeout: 15000,
  http_fetch_timeout: 10000
