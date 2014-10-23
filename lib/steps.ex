defmodule Steps do
  import Job, only: [default_image_format: 0]

  def to_command(steps) do
    do_to_command(steps, [])
    |> compact
    |> chain
  end

  defp do_to_command([], acc), do: acc |> Enum.reverse
  defp do_to_command([["f" | [file]] | tail], acc) do
    do_to_command(tail, [{:fetch, adapter.url_from_path(file)} | acc])
  end
  defp do_to_command([["fu" | [url]] | tail], acc) do
    do_to_command(tail, [{:fetch, url} | acc])
  end
  defp do_to_command([["p", "thumb", size] | tail], acc) do
    normalized = ["p", "convert", "-thumbnail #{size}", default_image_format]
    do_to_command([normalized | tail], acc)
  end
  defp do_to_command([["p", "convert", instructions, format] | tail], acc) do
    do_to_command(tail, [{:format, format} | [{:convert, instructions} | acc]])
  end
  defp do_to_command([["e", format] | tail], acc) do
    do_to_command(tail, [{:format, format} | acc])
  end

  defp compact(commands) do
    do_compact(commands, %{})
  end

  defp do_compact([], acc), do: acc
  defp do_compact([{operation, instructions} | tail], acc) do
    new_acc = Map.update(acc, operation, [instructions], fn(previous_instructions) ->
      [instructions | previous_instructions]
    end)
    do_compact(tail, new_acc)
  end

  defp chain(%{fetch: [fetch], convert: converts, format: [format]}) do
    %{
      fetch: fetch,
      shell: join_converts(converts |> Enum.reverse, format),
      format: format
    }
  end
  defp chain(%{fetch: [fetch], convert: converts}) do
    chain(%{fetch: [fetch], convert: converts, format: [default_image_format]})
  end
  defp chain(%{fetch: [fetch]}) do
    %{fetch: fetch}
  end

  defp join_converts(converts, format) do
    [
      "#{convert_command} - ",
      Enum.join(converts, " #{format}:- | #{convert_command} - "),
      " #{format}:-"
    ] |> Enum.join("")
  end

  defp convert_command do
    Application.get_env(:processor, :convert_command)
  end

  defp adapter do
    HttpEngine
  end
end
