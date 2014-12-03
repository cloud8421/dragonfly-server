defmodule Engines.HttpSup do
  def start do
    import Supervisor.Spec, warn: false

    :ets.new(http_engine_cache_table_name, [:named_table, :public, {:read_concurrency, true}])

    children = [
      worker(Engines.Http, [])
    ]

    opts = [strategy: :one_for_one,
            max_restarts: 10,
            max_seconds: 1,
            name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

  def http_engine_cache_table_name, do: :http_engine_cache
end
