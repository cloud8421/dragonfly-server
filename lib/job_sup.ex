defmodule JobSup do
  use Supervisor
  alias DragonflyServer.Config

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
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

    supervise(children, opts)
  end
end
