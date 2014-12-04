defmodule Job.Cache.MemcachedStore do
  use GenServer

  ## Callbacks

  def start_link(pool_names) do
    GenServer.start_link(__MODULE__, pool_names, name: __MODULE__)
  end

  def init(pool_names) do
    {:ok, pool_names}
  end
end
