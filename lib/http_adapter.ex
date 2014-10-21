defmodule HttpAdapter do
  use GenServer
  @cache_table_name :http_adapter_cache

  def fetch(path) do
    GenServer.call(__MODULE__, {:fetch, path})
  end

  ## Callbacks

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    :ets.new(@cache_table_name, [:named_table])
    {:ok, []}
  end

  def handle_call({:fetch, path}, _from, state) do
    case :ets.lookup(@cache_table_name, path) do
      [] ->
        data = remote_fetch(path)
        :ets.insert(@cache_table_name, {path, data})
        {:reply, data, state}
      [{^path, cached_data}] ->
        {:reply, cached_data, state}
    end
  end

  ## Private

  defp remote_fetch(path) do
    %HTTPoison.Response{body: image_binary, status_code: 200} = HTTPoison.get!(host <> "/" <> path)
    image_binary
  end

  defp host do
    System.get_env("HTTP_HOST")
  end
end
