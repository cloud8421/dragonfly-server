defmodule HttpEngine do
  use GenServer
  alias DragonflyServer.Config

  def fetch(url) do
    GenServer.call(__MODULE__, {:fetch, url}, Config.http_fetch_timeout)
  end

  def expire(url) do
    GenServer.cast(__MODULE__, {:expire, url})
  end

  def url_from_path(path) do
    host <> "/" <> path
  end

  ## Callbacks

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def handle_call({:fetch, url}, _from, state) do
    case :ets.lookup(table_name, url) do
      [] ->
        data = remote_fetch(url)
        :ets.insert(table_name, {url, data})
        {:reply, data, state}
      [{^url, cached_data}] ->
        {:reply, cached_data, state}
    end
  end

  def handle_cast({:expire, url}, state) do
    :ets.delete(table_name, url)
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
    DragonflyServer.http_engine_cache_table_name
  end
end
