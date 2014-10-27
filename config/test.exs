use Mix.Config

config :logger, :console,
  level: :error

config :processor,
  convert_command: System.get_env("CONVERT_COMMAND") || "/usr/local/bin/convert",
  http_timeout: 500
