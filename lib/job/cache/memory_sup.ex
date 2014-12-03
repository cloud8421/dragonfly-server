defmodule Job.Cache.MemorySup do
  def job_cache_table_name, do: :job_cache

  def start do
    import Supervisor.Spec, warn: false

    :ets.new(job_cache_table_name, [:named_table, :public, {:read_concurrency, true}])

    children = [
      worker(Job.Cache.MemoryStore, [])
    ]

    opts = [strategy: :one_for_one,
            max_restarts: 10,
            max_seconds: 1,
            name: __MODULE__]
    Supervisor.start_link(children, opts)
  end
end
