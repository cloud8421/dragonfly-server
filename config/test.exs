use Mix.Config

config :logger, :console,
  level: :error

config :cache,
  store: :memory
