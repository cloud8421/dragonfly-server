defmodule JobCacheStore do
  use GenServer
  @cache_table_name :responses_cache

  def get(cache_key) do
    case :ets.lookup(@cache_table_name, cache_key) do
      [] -> nil
      [{_key, content}] -> content
    end
  end

  def set(cache_key, value) do
    GenServer.cast(__MODULE__, {:set, cache_key, value})
  end

  ## Callbacks

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    :ets.new(@cache_table_name, [:named_table])
    {:ok, []}
  end

  def handle_cast({:set, cache_key, value}, state) do
    :ets.insert(@cache_table_name, {cache_key, value})
    {:noreply, state}
  end
end
