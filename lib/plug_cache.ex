defmodule Plug.Cache do
  @behaviour Plug
  import Plug.Conn

  def init([]) do
    []
  end

  def call(conn, []) do
    process(conn)
  end

  defp process(conn = %Plug.Conn{method: method}) when method == "GET" do
    get_req_header(conn, "if-none-match")
    |> build_response(conn)
    |> send_resp
  end
  defp process(conn), do: conn

  defp build_response([], conn) do
    new_etag = Crypt.sha256(conn.resp_body)
    put_resp_header(conn, "ETag", new_etag)
  end
  defp build_response([etag], conn) do
    new_etag = Crypt.sha256(conn.resp_body)
    response_for_etag(etag, new_etag, conn)
  end

  defp response_for_etag(etag, etag, conn) do
    conn
    |> put_resp_header("Etag", etag)
    |> resp(304, "")
  end
  defp response_for_etag(_etag, new_etag, conn) do
    put_resp_header(conn, "ETag", new_etag)
  end
end
