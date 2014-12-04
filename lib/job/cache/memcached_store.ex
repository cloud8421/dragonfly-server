defmodule Job.Cache.MemcachedStore do
  use GenServer

  ## Callbacks

  def delete(cache_key) do
    GenServer.cast(__MODULE__, {:delete, cache_key})
  end

  def get(cache_key) do
    GenServer.call(__MODULE__, {:get, cache_key})
  end

  def set(cache_key, format, value) do
    GenServer.cast(__MODULE__, {:set, cache_key, format, value})
  end

  ## Callbacks

  def handle_call({:get, cache_key}, _from, state) do
    result = with_random_pool(state, fn(w) ->
      Job.Cache.MemcachedStoreWorker.get(w, cache_key)
    end)
    {:reply, result, state}
  end

  def handle_cast({:set, cache_key, format, value}, state) do
    with_random_pool(state, fn(w) ->
      Job.Cache.MemcachedStoreWorker.set(w, cache_key, format, value)
    end)
    {:noreply, state}
  end

  def handle_cast({:delete, cache_key}, state) do
    with_random_pool(state, fn(w) ->
      Job.Cache.MemcachedStoreWorker.delete(w, cache_key)
    end)
    {:noreply, state}
  end

  def start_link(pool_names) do
    GenServer.start_link(__MODULE__, pool_names, name: __MODULE__)
  end

  def init(pool_names) do
    {:ok, pool_names}
  end

  ## Private

  def with_random_pool(pool_names, func) do
    :random.seed(:os.timestamp)
    pool = pool_names |> Enum.shuffle |> List.first
    :poolboy.transaction(pool, fn(worker) ->
      func.(worker)
    end)
  end
end
