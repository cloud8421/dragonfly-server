defmodule Payload do
  use Jazz

  def decode(payload) do
    Base64.decode(payload)
    |> JSON.decode!
  end
end
