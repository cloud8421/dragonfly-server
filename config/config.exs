# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :processor,
  job_worker_timeout: 15000,
  job_worker_pool_size: 50,
  http_fetch_timeout: 10000,
  convert_command: "convert"

# config :cache,
#   store: :memcached
#
# config :web_server,
#   acceptors: 50
#
# config :security,
#   verify_urls: true,
#   secret: "my-secret"
#
# config :storage,
#   base_path: "./"

import_config "#{Mix.env}.exs"
