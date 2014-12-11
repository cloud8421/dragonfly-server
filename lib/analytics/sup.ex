defmodule Analytics.Sup do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    children = [
      worker(:statman_aggregator, [])
    ]

    opts = [strategy: :one_for_one,
            max_restarts: 5,
            max_seconds: 10,
            name: __MODULE__]

    supervise(children, opts)
  end
end
