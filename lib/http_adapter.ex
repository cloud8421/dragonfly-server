defmodule HttpAdapter do
  use GenServer

  def fetch(url) do
    GenServer.call(__MODULE__, {:fetch, url})
  end

  def expire(job) do
    GenServer.cast(__MODULE__, {:expire, job.fetch})
  end

  def url_from_path(path) do
    host <> "/" <> path
  end

  ## Callbacks

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def handle_call({:fetch, path}, _from, state) do
    case :ets.lookup(table_name, path) do
      [] ->
        data = remote_fetch(path)
        :ets.insert(table_name, {path, data})
        {:reply, data, state}
      [{^path, cached_data}] ->
        {:reply, cached_data, state}
    end
  end

  def handle_cast({:expire, path}, state) do
    :ets.delete(table_name, path)
    {:noreply, state}
  end

  ## Private

  defp remote_fetch(url) do
    %HTTPoison.Response{body: image_binary, status_code: 200} = HTTPoison.get!(url)
    image_binary
  end

  defp host do
    System.get_env("HTTP_HOST")
  end

  defp table_name do
    DragonflyServer.http_adapter_cache_table_name
  end
end
