defmodule Stats do
  def collect do
    %{
      available_workers: GenServer.call(:dragonfly_worker_pool, :get_avail_workers)
                         |> Enum.count
    }
  end

  def to_json(data) do
    {:ok, json} = JSX.encode(data)
    json
  end
end
