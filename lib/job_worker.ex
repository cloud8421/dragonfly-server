defmodule JobWorker do
  use GenServer

  ## Public api

  def process(worker, job) do
    GenServer.call(worker, {:process, job}, http_timeout)
  end

  def expire(worker, job) do
    GenServer.call(worker, {:expire, job})
  end

  ## Callbacks

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def init(_opts) do
    {:ok, []}
  end

  def handle_call({:process, job}, _from, state) do
    data = Job.process(job)
    {:reply, data, state}
  end

  def handle_call({:expire, job}, _from, state) do
    Job.expire(job)
    {:reply, :ok, state}
  end

  ## Private

  defp http_timeout, do: Application.get_env(:processor, :http_timeout)
end
