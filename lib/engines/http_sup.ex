defmodule Engines.HttpSup do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    :ets.new(http_engine_cache_table_name, [:named_table, :public, {:read_concurrency, true}])

    children = [
      worker(Engines.Http, [])
    ]

    opts = [strategy: :one_for_one,
            max_restarts: 10,
            max_seconds: 1,
            name: __MODULE__]

    supervise(children, opts)
  end

  def http_engine_cache_table_name, do: :http_engine_cache
end
