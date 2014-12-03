defmodule DragonflyServer do
  use Application
  alias DragonflyServer.Config

  def start(_type, _args) do
    Plug.Adapters.Cowboy.http WebServer, [], port: Config.http_port,
                                             acceptors: Config.http_acceptors,
                                             compress: true
    start_workers
    Job.Cache.MemorySup.start
    Engines.HttpSup.start
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
end
