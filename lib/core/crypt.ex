# extracted from https://github.com/inkr/cryptic/blob/master/lib/cryptic/hash.ex

defmodule Crypt do
  def hmac256(term, key) do
    bitstring = :crypto.hmac(:sha256, key, term, 16)
    bitstring_to_hexstring(bitstring)
  end

  def sha256(term) do
    bitstring = :crypto.hash(:sha256, term)
    bitstring_to_hexstring(bitstring)
  end

  defp bitstring_to_hexstring(bitstring) do
    :erlang.bitstring_to_list(bitstring)
    |> Enum.map(fn(x) ->
        [list] = :io_lib.format("~2.16.0b", [x])
        :erlang.list_to_bitstring(list)
      end)
    |> Enum.join ""
  end
end
