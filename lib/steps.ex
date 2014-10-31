defmodule Steps do
  import Job, only: [default_image_format: 0]
  import Job.Sanitize

  def deserialize(steps) do
    do_deserialize(steps, [])
    |> compact
    |> chain
  end

  defp do_deserialize([], acc), do: acc |> Enum.reverse
  defp do_deserialize([["f" | [file]] | tail], acc) do
    do_deserialize(tail, [{:fetch, HttpEngine.url_from_path(file)} | acc])
  end
  defp do_deserialize([["fu" | [url]] | tail], acc) do
    do_deserialize(tail, [{:fetch, url} | acc])
  end
  defp do_deserialize([["ff" | [path]] | tail], acc) do
    do_deserialize(tail, [{:file, path} | acc])
  end
  defp do_deserialize([["p", "thumb", size] | tail], acc) do
    normalized = ["p", "convert", "-thumbnail #{size}", default_image_format]
    do_deserialize([normalized | tail], acc)
  end
  defp do_deserialize([["p", "convert", instructions, format] | tail], acc) do
    do_deserialize(tail, [{:format, format} | [{:convert, instructions} | acc]])
  end
  defp do_deserialize([["e", format] | tail], acc) do
    do_deserialize(tail, [{:format, format} | acc])
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

  defp chain(%{fetch: [url], convert: converts, format: [format]}) do
    sanitized_format = format |> sanitize_format
    %{
      fetch: url,
      shell: join_converts(converts |> Enum.reverse, sanitized_format),
      format: sanitized_format
    }
  end
  defp chain(%{fetch: [url], convert: converts}) do
    chain(%{fetch: [url], convert: converts, format: [default_image_format]})
  end
  defp chain(%{fetch: [url]}) do
    %{fetch: url}
  end

  defp chain(%{file: [path], convert: converts, format: [format]}) do
    sanitized_format = format |> sanitize_format
    %{
      file: path,
      shell: join_converts(converts |> Enum.reverse, sanitized_format),
      format: sanitized_format
    }
  end
  defp chain(%{file: [path], convert: converts}) do
    chain(%{file: [path], convert: converts, format: [default_image_format]})
  end
  defp chain(%{file: [path]}) do
    %{file: path}
  end

  defp join_converts(converts, format) do
    [
      "#{convert_command} - ",
      Enum.join(converts, " #{format}:- | #{convert_command} - "),
      " -strip #{format}:-"
    ] |> Enum.join("")
  end

  defp convert_command do
    Application.get_env(:processor, :convert_command)
  end
end
