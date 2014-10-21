defmodule ProcessWorker do
  use GenServer

  ## Public api

  def process(worker, job) do
    GenServer.call(worker, {:process, job})
  end

  ## Callbacks

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def init(_opts) do
    {:ok, []}
  end

  def handle_call({:process, job}, _from, state) do
    data = Runner.process(job)
    {:reply, data, state}
  end
end
