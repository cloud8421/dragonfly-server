defmodule Engines.Http do
  use GenServer
  import Config, only: [http_engine_host: 0]

  def fetch(url) do
    GenServer.call(__MODULE__, {:fetch, url}, Config.http_fetch_timeout)
  end

  def expire(url) do
    GenServer.cast(__MODULE__, {:expire, url})
  end

  def url_from_path(path) do
    http_engine_host <> "/" <> path
  end

  ## Callbacks

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def handle_call({:fetch, url}, _from, state) do
    case :ets.lookup(table_name, url) do
      [] ->
        case remote_fetch(url) do
          {:ok, data} ->
            :ets.insert(table_name, {url, data})
            {:reply, data, state, :hibernate}
          error = {:error, reason} ->
            {:reply, error, state, :hibernate}
        end
      [{^url, cached_data}] ->
        {:reply, cached_data, state, :hibernate}
    end
  end

  def handle_cast({:expire, url}, state) do
    :ets.delete(table_name, url)
    {:noreply, state, :hibernate}
  end

  ## Private

  defp remote_fetch(url) do
    case HTTPoison.get!(url) do
      %HTTPoison.Response{body: image_binary, status_code: 200} ->
        {:ok, image_binary}
      _ -> {:error, :not_found}
    end
  end

  defp table_name do
    Engines.HttpSup.http_engine_cache_table_name
  end
end
