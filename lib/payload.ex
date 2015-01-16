defmodule Payload do
  def decode(payload) do
    {:ok, decoded} = Base64.decode(payload)
    |> JSX.decode
    decoded
  end
end
