defmodule Steps do
  import Job.Sanitize

  @default_image_format "jpg"

  defstruct fetch: nil,
            file: nil,
            convert: [],
            format: @default_image_format

  def deserialize(steps) do
    do_deserialize(steps, %Steps{})
    |> compact
  end

  defp do_deserialize([], acc), do: acc
  defp do_deserialize([["f" | [file]] | tail], acc) do
    do_deserialize(tail, %Steps{acc | fetch: HttpEngine.url_from_path(file)})
  end
  defp do_deserialize([["fu" | [url]] | tail], acc) do
    do_deserialize(tail, %Steps{acc | fetch: url})
  end
  defp do_deserialize([["ff" | [path]] | tail], acc) do
    do_deserialize(tail, %Steps{acc | file: path})
  end
  defp do_deserialize([["p", "thumb", size] | tail], acc) do
    normalized = ["p", "convert", "-thumbnail #{size}", @default_image_format]
    do_deserialize([normalized | tail], acc)
  end
  defp do_deserialize([["p", "convert", instructions, format] | tail], acc) do
    new_acc = %Steps{acc | format: format, convert: [instructions | acc.convert]}
    do_deserialize(tail, new_acc)
  end
  defp do_deserialize([["e", format] | tail], acc) do
    do_deserialize(tail, %Steps{acc | format: format})
  end

  defp compact(steps) do
    normalized_converts = steps.convert
                          |> Enum.reverse
                          |> join_converts(steps.format)
    sanitized_format = sanitize_format(steps.format)
    %Steps{steps | convert: normalized_converts, format: sanitized_format}
  end

  defp join_converts([], _format), do: []
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
