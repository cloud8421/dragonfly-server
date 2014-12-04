defmodule Job.Cache.MemcachedSup do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    children = [init_store | build_poolboy_options]

    opts = [strategy: :one_for_one, name: __MODULE__]
    supervise(children, opts)
  end

  defp init_store do
    pool_names = Config.memcached_servers
                 |> Enum.map(fn({name, _data}) -> name end)
    worker(Job.Cache.MemcachedStore, [pool_names], [])
  end

  defp build_poolboy_options do
    worker_pool_options = [
      worker_module: Job.Cache.MemcachedStoreWorker,
      size: 4,
      max_overflow: 2
    ]

    Enum.map(Config.memcached_servers, fn({name, conf}) ->
      opts = worker_pool_options ++ [name: {:local, name}]
      :poolboy.child_spec(name, opts, conf)
    end)
  end
end
