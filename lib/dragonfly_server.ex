defmodule DragonflyServer do
  use Application
  alias DragonflyServer.Config

  def start(_type, _args) do
    import Supervisor.Spec
    Plug.Adapters.Cowboy.http WebServer, [], port: Config.http_port,
                                             acceptors: Config.http_acceptors,
                                             compress: true

    children = [
      supervisor(cache_sup(Config.cache_store), []),
      supervisor(Job.Sup, []),
      supervisor(Engines.HttpSup, [])
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]

    Supervisor.start_link(children, opts)
  end

  defp cache_sup(:memory), do: Job.Cache.MemorySup
  defp cache_sup(:memcached), do: Job.Cache.MemcachedSup

  def cache_store, do: do_cache_store(Config.cache_store)

  defp do_cache_store(:memory), do: Job.Cache.MemoryStore
  defp do_cache_store(:memcached), do: Job.Cache.MemcachedStore
end
