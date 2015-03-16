defmodule Stats do
  def collect do
    stats = :recon.node_stats_list(1, 50)
    %{
      available_workers: GenServer.call(:dragonfly_worker_pool, :get_avail_workers)
                         |> Enum.count,
      bin_memory_usage_in_kb: stats |> extract_binary_memory_usage,
      total_memory_usage_in_kb: stats |> extract_total_memory_usage,
      procs_by_memory: procs_by_memory
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

  defp procs_by_memory do
    procs = :recon.proc_count(:binary_memory, 10)
    Enum.map(procs, fn({_pid, memory, data}) ->
      {data |> format_memory_info, memory |> div 1024}
    end)
  end

  defp format_memory_info([name, _func, _initial]), do: name
  defp format_memory_info([_func, _initial]), do: "anonymous_function"
end
