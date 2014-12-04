defmodule Job.Cache.MemorySup do
  use Supervisor

  def job_cache_table_name, do: :job_cache

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    :ets.new(job_cache_table_name, [:named_table, :public, {:read_concurrency, true}])

    children = [
      worker(Job.Cache.MemoryStore, [])
    ]

    opts = [strategy: :one_for_one,
            max_restarts: 10,
            max_seconds: 1,
            name: __MODULE__]
    supervise(children, opts)
  end
end
