defmodule WebRouter do
  import Plug.Conn
  use Plug.Router

  # Plug order matters, as they are inserted as middlewares
  plug Plug.Head
  plug :match
  plug :dispatch

  get "/media/:payload/:filename" do
    response = case JobCacheStore.get(payload) do
      nil ->
        data = compute_image(payload)
        JobCacheStore.set(payload, data)
        data
      content -> content
    end
    send_resp(conn, 200, response)
  end

  match _ do
    send_resp(conn, 404, "Image not found")
  end

  defp compute_image(payload) do
    :poolboy.transaction(:dragonfly_worker_pool, fn(worker) ->
      JobWorker.process(worker, payload)
    end)
  end
end
