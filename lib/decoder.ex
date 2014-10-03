defmodule Decoder do
  use Jazz

  def decode(base_64_payload) when is_binary(base_64_payload) do
    do_decode(base_64_payload, String.length(base_64_payload))
  end

  defp do_decode(base_64_payload, length) when rem(length, 4) == 0 do
    :base64.decode(base_64_payload) |> JSON.decode!
  end
  defp do_decode(base_64_payload, length) do
    {padded_length, padded_payload} = pad(base_64_payload, length)
    do_decode(padded_payload, padded_length)
  end

  defp pad(base_64_payload, length) do
    missing_chars = rem(length, 4)
    padding = Range.new(1, missing_chars)
              |> Enum.map(fn(_i) -> "=" end)
              |> Enum.join
    {length + missing_chars, base_64_payload <> padding}
  end
end
