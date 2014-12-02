use Mix.Config

config :logger, :console,
  level: :info, metadata: [:request_id]
