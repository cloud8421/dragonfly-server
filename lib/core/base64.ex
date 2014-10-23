defmodule Base64 do
  def decode(encoded) when is_binary(encoded) do
    do_decode(encoded, String.length(encoded))
  end

  defp do_decode(encoded, length) when rem(length, 4) == 0 do
    :base64.decode(encoded)
  end
  defp do_decode(encoded, length) do
    {padded_length, padded_payload} = pad(encoded, length)
    do_decode(padded_payload, padded_length)
  end

  defp pad(encoded, length) do
    padded_length = (div(length, 4) + 1) * 4
    padded_payload = String.ljust(encoded, padded_length, ?=)
    {padded_length, padded_payload}
  end
end
