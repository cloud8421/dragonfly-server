defmodule JobCacheStore do
  use GenServer
  @cache_table_name :responses_cache

  def delete(cache_key) do
    GenServer.cast(__MODULE__, {:delete, cache_key})
  end

  def get(cache_key) do
    case :ets.lookup(@cache_table_name, cache_key) do
      [] -> nil
      [{_key, format, content}] -> {format, content}
    end
  end

  def set(cache_key, format, value) do
    GenServer.cast(__MODULE__, {:set, cache_key, format, value})
  end

  ## Callbacks

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    :ets.new(@cache_table_name, [:named_table])
    {:ok, []}
  end

  def handle_cast({:set, cache_key, format, value}, state) do
    :ets.insert(@cache_table_name, {cache_key, format, value})
    {:noreply, state}
  end

  def handle_cast({:delete, cache_key}, state) do
    :ets.delete(@cache_table_name, cache_key)
    {:noreply, state}
  end
end
