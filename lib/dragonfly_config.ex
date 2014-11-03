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
end
