defmodule Plug.NewRelic do
  @behaviour Plug
  alias Plug.Conn

  def init([]) do
    []
  end

  def call(conn, []) do
    start = :erlang.now()
    Conn.register_before_send(conn, fn(conn) ->
      path = Conn.full_path(conn)
      :statman_histogram.record_value({path, :total}, start)
      conn
    end)
  end
end
