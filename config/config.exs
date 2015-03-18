# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :processor,
  job_worker_timeout: 15000,
  job_worker_pool_size: 10,
  http_fetch_timeout: 10000,
  convert_command: "convert"

# mount_at defines the entry point for the api. It has to contain
# a :payload and a :filename param
config :web_server,
  mount_at: "/media/:payload/:filename"
  # acceptors: 50

# config :cache,
#   store: :memcached
#
# config :security,
#   verify_urls: true,
#   secret: "my-secret"
#
# config :storage,
#   base_path: "./"

import_config "#{Mix.env}.exs"
