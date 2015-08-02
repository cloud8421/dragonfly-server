defmodule Config do
  def http_port, do: do_http_port(System.get_env("PORT"))

  defp do_http_port(nil), do: 4000
  defp do_http_port(port_string), do: String.to_integer(port_string)

  def http_acceptors do
    Application.get_env(:web_server, :acceptors) || 50
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

  def http_engine_host do
    System.get_env("HTTP_ENGINE_HOST")
  end

  def aws_access_key_id do
    System.get_env("AWS_ACCESS_KEY_ID")
    || System.get_env("AMAZON_ACCESS_KEY_ID")
    || System.get_env("AWS_ACCESS_KEY")
  end

  def aws_secret_access_key do
    System.get_env("AWS_SECRET_ACCESS_KEY")
    || System.get_env("AMAZON_SECRET_ACCESS_KEY")
    || System.get_env("AWS_SECRET_KEY")
  end

  def aws_region do
    System.get_env("AWS_REGION")
    || System.get_env("AMAZON_REGION")
    || System.get_env("AWS_DEFAULT_REGION")
    || "us-east-1"
  end

  def sign_urls do
    Application.get_env(:processor, :sign_urls) || false
  end

  def fs_base_path do
    Application.get_env(:storage, :base_path) || System.cwd
  end

  def worker_pool_size do
    Application.get_env(:processor, :job_worker_pool_size) || 50
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

  def cache_store do
    do_cache_store(Application.get_env(:cache, :store))
  end

  defp do_cache_store(nil), do: :memory
  defp do_cache_store(:memory), do: :memory
  defp do_cache_store(:memcached), do: :memcached

  def memcached_servers do
    do_memcached_servers(System.get_env("MEMCACHED_SERVERS"))
  end

  def memcached_username do
    System.get_env("MEMCACHED_USERNAME")
  end

  def memcached_password do
    System.get_env("MEMCACHED_PASSWORD")
  end

  def memcached_needs_auth? do
    memcached_username && memcached_password
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

  def new_relic_license do
    System.get_env("NEW_RELIC_LICENSE_KEY")
  end
end
