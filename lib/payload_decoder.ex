defmodule PayloadDecoder do
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
    padded_length = (div(length, 4) + 1) * 4
    padded_payload = String.ljust(base_64_payload, padded_length, ?=)
    {padded_length, padded_payload}
  end
end
