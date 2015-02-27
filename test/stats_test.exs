defmodule StatsTest do
  use ExUnit.Case

  import Mock

  test "it reports memory usage" do
    stats_list = [{[process_count: 236, run_queue: 0, error_logger_queue_len: 0,
                    memory_total: 80404720, memory_procs: 5597224, memory_atoms: 539116,
                    memory_bin: 44650912, memory_ets: 1441144],
                  [bytes_in: 0, bytes_out: 0, gc_count: 1, gc_words_reclaimed: 5321,
                    reductions: 11102,
                    scheduler_usage: [{1, 0.14213197969543148}, {2, 1.0},
                      {3, 0.14646464646464646}, {4, 0.1414141414141414}]]}]

    with_mock :recon, [node_stats_list: fn(_repeat, _interval) -> stats_list end] do
      stats = Stats.collect
      assert stats.total_memory_usage_in_kb == 78520
      assert stats.bin_memory_usage_in_kb == 43604
    end
  end
end
