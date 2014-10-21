defmodule DragonflyServer do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    worker_pool_options = [
      name: {:local, :dragonfly_worker_pool},
      worker_module: JobWorker,
      size: Application.get_env(:process_worker_pool, :size),
      max_overflow: Application.get_env(:process_worker_pool, :max_overflow)
    ]

    children = [
      :poolboy.child_spec(:dragonfly_worker_pool, worker_pool_options, []),
      worker(JobCacheStore, []),
      worker(HttpAdapter, [])
      # Define workers and child supervisors to be supervised
      # worker(DragonflyServer.Worker, [arg1, arg2, arg3])
    ]

    Plug.Adapters.Cowboy.http WebServer, [], port: System.get_env("PORT") |> String.to_integer,
                                             acceptors: Application.get_env(:web_server, :acceptors),
                                             compress: true

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DragonflyServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
