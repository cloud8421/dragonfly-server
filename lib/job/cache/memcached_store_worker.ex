defmodule Job.Cache.MemcachedStoreWorker do
  use GenServer
  alias Memcache.Connection

  def delete(worker, cache_key) do
    GenServer.cast(worker, {:delete, cache_key})
  end

  def get(worker, cache_key) do
    GenServer.call(worker, {:get, cache_key})
  end

  def set(worker, cache_key, format, value) do
    GenServer.cast(worker, {:set, cache_key, format, value})
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  def init(opts) do
    server_opts = Map.to_list(opts)
    {:ok, mcd_pid} = Connection.start_link(server_opts)
    if Config.memcached_needs_auth? do
      authenticate!(mcd_pid)
    else
      {:ok, mcd_pid}
    end
  end

  def handle_call({:get, cache_key}, _from, mcd_pid) do
    data_result = Connection.execute(mcd_pid, :GET, [cache_key])
    format_result = Connection.execute(mcd_pid, :GET, ["#{cache_key}-format"])
    case {data_result, format_result} do
      {{:ok, data}, {:ok, format}} ->
        job_result = %Job.Result{format: format, data: data}
        {:reply, job_result, mcd_pid, :hibernate}
      _ -> {:reply, nil, mcd_pid, :hibernate}
    end
  end

  def handle_cast({:set, cache_key, format, value}, mcd_pid) do
    { :ok } = Connection.execute(mcd_pid, :SET, ["#{cache_key}-format", format])
    { :ok } = Connection.execute(mcd_pid, :SET, [cache_key, value])
    {:noreply, mcd_pid, :hibernate}
  end

  def handle_cast({:delete, cache_key}, mcd_pid) do
    { :ok } = Connection.execute(mcd_pid, :DELETE, [cache_key])
    { :ok } = Connection.execute(mcd_pid, :DELETE, ["#{cache_key}-format"])
    {:noreply, mcd_pid, :hibernate}
  end

  defp authenticate!(mcd_pid) do
    case Connection.execute(mcd_pid, :AUTH_REQUEST, [Config.memcached_username, Config.memcached_password]) do
      {:ok, :authenticated} -> {:ok, mcd_pid}
      {:error, _} -> {:stop, :authentication_failure}
    end
  end
end
