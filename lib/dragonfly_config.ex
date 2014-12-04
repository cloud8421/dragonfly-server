defmodule DragonflyServer.Config do
  def http_port do
    (System.get_env("PORT") |> String.to_integer) || 4000
  end

  def http_acceptors do
    Application.get_env(:web_server, :acceptors) || 50
  end

  def worker_pool_size do
    Application.get_env(:process_worker_pool, :size) || 50
  end

  def worker_pool_max_overflow do
    worker_pool_size * 0.05 |> trunc
  end

  def verify_urls do
    Application.get_env(:security, :verify_urls) || false
  end

  def secret do
    Application.get_env(:security, :secret)
  end

  def fs_base_path do
    Application.get_env(:storage, :base_path) || System.cwd
  end

  def job_worker_timeout do
    Application.get_env(:processor, :job_worker_timeout) || 3000
  end

  def http_fetch_timeout do
    Application.get_env(:processor, :http_fetch_timeout) || 2000
  end

  def convert_command do
    Application.get_env(:processor, :convert_command) || "convert"
  end

  def memcached_servers do
    do_memcached_servers(System.get_env("MEMCACHED_SERVERS"))
  end

  defp do_memcached_servers(nil), do: nil
  defp do_memcached_servers(servers_string) do
    servers_string
    |> String.split(",")
    |> Enum.map(fn (x) -> String.split(x, ":") end)
    |> Enum.with_index
    |> Enum.map(fn ({[host, port], index}) ->
      name = String.to_atom("memcached#{index}")
      {name, %{hostname: host, port: String.to_integer(port)}}
    end)
  end
end
