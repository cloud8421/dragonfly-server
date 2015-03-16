defmodule Stats do
  def collect do
    stats = :recon.node_stats_list(1, 50)
    %{
      available_workers: GenServer.call(:dragonfly_worker_pool, :get_avail_workers)
                         |> Enum.count,
      bin_memory_usage_in_kb: stats |> extract_binary_memory_usage,
      total_memory_usage_in_kb: stats |> extract_total_memory_usage
    }
  end

  def to_json(data) do
    {:ok, json} = JSX.encode(data)
    json
  end

  defp extract_binary_memory_usage(stats) do
    [{data, _discard}] = stats
    data[:memory_bin] |> div 1024
  end

  defp extract_total_memory_usage(stats) do
    [{data, _discard}] = stats
    data[:memory_total] |> div 1024
  end
end
