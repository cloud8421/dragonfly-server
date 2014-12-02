defmodule DragonflyServer do
  use Application
  alias DragonflyServer.Config

  def job_cache_table_name, do: :job_cache
  def http_engine_cache_table_name, do: :http_engine_cache

  def start(_type, _args) do
    Plug.Adapters.Cowboy.http WebServer, [], port: Config.http_port,
                                             acceptors: Config.http_acceptors,
                                             compress: true
    start_workers
    start_caches
  end

  defp start_workers do
    import Supervisor.Spec, warn: false

    worker_pool_options = [
      name: {:local, :dragonfly_worker_pool},
      worker_module: JobWorker,
      size: Config.worker_pool_size,
      max_overflow: Config.worker_pool_max_overflow
    ]

    children = [
      :poolboy.child_spec(:dragonfly_worker_pool, worker_pool_options, []),
    ]

    opts = [strategy: :one_for_one, name: DragonflyServer.WorkerSupervisor]
    Supervisor.start_link(children, opts)
  end

  defp start_caches do
    import Supervisor.Spec, warn: false

    :ets.new(job_cache_table_name, [:named_table, :public, {:read_concurrency, true}])
    :ets.new(http_engine_cache_table_name, [:named_table, :public, {:read_concurrency, true}])

    children = [
      worker(Job.Cache.MemoryStore, []),
      worker(HttpEngine, [])
    ]

    opts = [strategy: :one_for_one,
            max_restarts: 10,
            max_seconds: 1,
            name: DragonflyServer.CacheSupervisor]
    Supervisor.start_link(children, opts)
  end
end
