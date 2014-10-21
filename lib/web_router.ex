defmodule WebRouter do
  import Plug.Conn
  use Plug.Router

  plug :match
  plug :dispatch

  get "/media/:payload/:filename" do
    processed = Runner.process(payload)
    send_resp(conn, 200, processed)
  end

  match _ do
    send_resp(conn, 404, "Image not found")
  end
end
