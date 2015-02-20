defmodule Job.Cache.MemoryStore do
  use GenServer

  def delete(cache_key) do
    GenServer.cast(__MODULE__, {:delete, cache_key})
  end

  def get(cache_key) do
    case :ets.lookup(table_name, cache_key) do
      [] -> nil
      [{_key, format, data}] ->
        %Job.Result{format: format, data: data}
    end
  end

  def set(cache_key, format, value) do
    GenServer.cast(__MODULE__, {:set, cache_key, format, value})
  end

  def clear do
    GenServer.cast(__MODULE__, :clear)
  end

  ## Callbacks

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def handle_cast({:set, cache_key, format, value}, state) do
    :ets.insert(table_name, {cache_key, format, value})
    {:noreply, state}
  end

  def handle_cast({:delete, cache_key}, state) do
    :ets.delete(table_name, cache_key)
    {:noreply, state}
  end

  def handle_cast(:clear, state) do
    :ets.delete_all_objects(table_name)
    {:noreply, state}
  end

  ## Private

  defp table_name do
    Job.Cache.MemorySup.job_cache_table_name
  end
end
