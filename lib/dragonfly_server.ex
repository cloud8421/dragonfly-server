defmodule DragonflyServer do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec
    Plug.Adapters.Cowboy.http WebServer, [], port: Config.http_port,
                                             acceptors: Config.http_acceptors,
                                             compress: true

    children = [
      supervisor(cache_sup(Config.cache_store), []),
      supervisor(Job.Sup, []),
      supervisor(Engines.HttpSup, []),
      supervisor(Analytics.Sup, [])
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]

    result = Supervisor.start_link(children, opts)

    if Mix.env == :prod do
      start_new_relic
    end

    result
  end

  defp cache_sup(:memory), do: Job.Cache.MemorySup
  defp cache_sup(:memcached), do: Job.Cache.MemcachedSup

  def cache_store, do: do_cache_store(Config.cache_store)

  defp do_cache_store(:memory), do: Job.Cache.MemoryStore
  defp do_cache_store(:memcached), do: Job.Cache.MemcachedStore

  defp start_new_relic do
    if Config.new_relic_license do
      license_key = Config.new_relic_license |> String.to_char_list
      name = "Dragonfly-#{Mix.env}" |> String.to_char_list
      :application.set_env(:newrelic, :license_key, license_key)
      :application.set_env(:newrelic, :application_name, name)
      :statman_server.add_subscriber(:statman_aggregator)
      :newrelic_poller.start_link(&:newrelic_statman.poll/0)
    end
  end
end
