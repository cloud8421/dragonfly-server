use Mix.Config

config :logger, :console,
  level: :info,
  metadata: [:request_id],
  handle_otp_reports: true,
  handle_sasl_reports: true

config :cache,
  store: :memcached
