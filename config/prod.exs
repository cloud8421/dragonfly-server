use Mix.Config

config :logger, :console,
  level: :info, metadata: [:request_id]

config :cache,
  store: :memcached
