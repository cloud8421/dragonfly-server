defmodule Steps do
  import Job, only: [default_image_format: 0]

  def to_command(steps) do
    do_to_command(steps, [])
    |> compact
    |> chain
  end

  defp do_to_command([], acc), do: acc |> Enum.reverse
  defp do_to_command([["f" | [file]] | tail], acc) do
    do_to_command(tail, [{:fetch, HttpEngine.url_from_path(file)} | acc])
  end
  defp do_to_command([["fu" | [url]] | tail], acc) do
    do_to_command(tail, [{:fetch, url} | acc])
  end
  defp do_to_command([["ff" | [path]] | tail], acc) do
    do_to_command(tail, [{:file, path} | acc])
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

  # Poor man's sanitize to avoid malicious formats:
  # anything that doesn't match will
  # cause a pattern match error, eventually crashing the worker that
  # performs the command.
  defp sanitize_format("jpg"), do: "jpg"
  defp sanitize_format("jpeg"), do: "jpg"
  defp sanitize_format("png"), do: "png"
  defp sanitize_format("gif"), do: "gif"

  defp convert_command do
    Application.get_env(:processor, :convert_command)
  end
end
