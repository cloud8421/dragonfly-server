defmodule DragonflyServer do
  use Application
  alias DragonflyServer.Config

  def start(_type, _args) do
    import Supervisor.Spec
    Plug.Adapters.Cowboy.http WebServer, [], port: Config.http_port,
                                             acceptors: Config.http_acceptors,
                                             compress: true

    children = [
      supervisor(JobSup, []),
      supervisor(Job.Cache.MemorySup, []),
      supervisor(Job.Cache.MemcachedSup, []),
      supervisor(Engines.HttpSup, [])
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]

    Supervisor.start_link(children, opts)
  end
end
