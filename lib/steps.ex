defmodule Steps do
  import Job.Sanitize
  import DragonflyServer.Config, only: [convert_command: 0]
  use Jazz

  @default_image_format "jpg"

  defstruct fetch: nil,
            file: nil,
            convert: [],
            format: @default_image_format

  def to_json(steps_struct) do
    JSON.encode! steps_struct
  end

  def deserialize(decoded_payload) do
    do_deserialize(decoded_payload, %Steps{})
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
    # The `-` after the first convert command tells ImageMagick to use stdin
    # The `-strip` flag removes exif data from the images
    # The `jpeg:-` notation tells ImageMagick to pipe the output to stdout in the
    # specified format

    joined_converts = Enum.join(converts, " #{format}:- | #{convert_command} - ")
    "#{convert_command} - #{joined_converts} -strip #{format}:-"
  end
end
