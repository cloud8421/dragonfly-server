defmodule Engines.HttpSup do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    children = [
      worker(Engines.Http, [])
    ]

    opts = [strategy: :one_for_one,
            max_restarts: 10,
            max_seconds: 1,
            name: __MODULE__]

    supervise(children, opts)
  end
end
