defmodule WebServerTest do
  use ExUnit.Case
  use Plug.Test

  @opts WebServer.init([])

  test "it sends 404 when none matches" do
    req = conn(:get, "/foo")
          |> WebServer.call(@opts)
    assert req.state == :sent
    assert req.status == 404
  end
end
