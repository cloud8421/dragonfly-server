defmodule WebRouter do
  import Plug.Conn
  use Plug.Router

  # Plug order matters, as they are inserted as middlewares
  plug Plug.Head
  plug :match
  plug :dispatch

  get "/media/:payload/:filename" do
    {format, response} = case JobCacheStore.get(payload) do
      nil ->
        {format, data} = compute_image(payload)
        JobCacheStore.set(payload, format, data)
        {format, data}
      match -> match
    end
    conn_with_headers = add_headers(conn, format, filename)
    send_resp(conn_with_headers, 200, response)
  end

  match _ do
    send_resp(conn, 404, "Image not found")
  end

  defp compute_image(payload) do
    :poolboy.transaction(:dragonfly_worker_pool, fn(worker) ->
      JobWorker.process(worker, payload)
    end)
  end

  defp add_headers(conn, format, filename) do
    with_ct = put_resp_header(conn, "Content-Type", header_for_format(format))
    put_resp_header(with_ct, "Content-Disposition", "filename=\"#{filename}\"")
  end

  defp header_for_format("jpg"), do: "image/jpg"
  defp header_for_format("png"), do: "image/png"
end
