defmodule Job.Cache.MemcachedStoreWorker do
  use GenServer

  def delete(cache_key) do
    # GenServer.cast(__MODULE__, {:delete, cache_key})
  end

  def get(cache_key) do
    # case :ets.lookup(table_name, cache_key) do
    #   [] -> nil
    #   [{_key, format, content}] -> {format, content}
    # end
  end

  def set(cache_key, format, value) do
    # GenServer.cast(__MODULE__, {:set, cache_key, format, value})
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  def init(opts) do
    server_opts = Map.to_list(opts)
    mcd_pid = Memcache.Connection.start_link(server_opts)
    {:ok, mcd_pid}
  end

  def handle_cast({:set, cache_key, format, value}, state) do
    # :ets.insert(table_name, {cache_key, format, value})
    {:noreply, state}
  end

  def handle_cast({:delete, cache_key}, state) do
    # :ets.delete(table_name, cache_key)
    {:noreply, state}
  end
end
