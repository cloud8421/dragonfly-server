defmodule WebRouter do
  import Plug.Conn
  use Plug.Router

  @max_age 31536000 # 1 year
  @url_scheme "/media/:payload/:filename"

  # Plug order matters, as they are inserted as middlewares
  if Mix.env == :prod do
    plug Plug.NewRelic
  end
  plug Plug.Logger
  plug Plug.Head
  plug :match
  plug :dispatch
  plug Plug.Cache

  if Mix.env == :dev do
    use Plug.Debugger, otp_app: :dragonfly_server
  end

  get "/stats" do
    resp(conn, 200, Stats.collect |> Stats.to_json)
  end

  delete "/admin#{@url_scheme}" do
    :ok = expire_image(payload)
    resp(conn, 202, "Scheduled deletion")
  end

  get "/admin#{@url_scheme}" do
    if verify_payload(conn, payload) do
      data = examine_image(payload)
             |> Steps.to_json
      conn
      |> put_resp_content_type("application/json")
      |> resp(200, data)
    else
      resp(conn, 404, "Image not found")
    end
  end

  get @url_scheme do
    conn
    |> fetch_params
    |> handle_image_response(payload, filename)
  end

  match _ do
    resp(conn, 404, "Image not found")
  end

  defp handle_image_response(conn, payload, filename) do
    if verify_payload(conn, payload) do
      {format, response} = fetch_or_compute_image(payload)
      case response do
        {:error, error} -> conn |> resp(422, error |> to_string)
        {:ok, data} -> conn
              |> add_headers(format, filename)
              |> resp(200, data)
      end
    else
      conn |> resp(401, "Not a valid sha")
    end
  end

  defp fetch_or_compute_image(payload) do
    case DragonflyServer.cache_store.get(payload) do
      nil -> compute_image(payload)
      match -> match
    end
  end

  defp verify_payload(conn, payload) do
    if needs_to_verify_urls do
      case conn.params do
        %{"sha" => sha} -> is_genuine_job(sha, payload)
        _ -> false
      end
    else
      true
    end
  end

  defp is_genuine_job(sha, payload) do
    sha == Job.hash_from_payload(payload)
  end

  defp compute_image(payload) do
    :poolboy.transaction(:dragonfly_worker_pool, fn(worker) ->
      Job.Worker.process(worker, payload)
    end)
  end

  def examine_image(payload) do
    :poolboy.transaction(:dragonfly_worker_pool, fn(worker) ->
      Job.Worker.examine(worker, payload)
    end)
  end

  def expire_image(payload) do
    :poolboy.transaction(:dragonfly_worker_pool, fn(worker) ->
      Job.Worker.expire(worker, payload)
    end)
  end

  defp add_headers(conn, format, filename) do
    conn
    |> put_resp_header("Content-Type", header_for_format(format))
    |> put_resp_header("cache-control", "public, max-age=#{@max_age}")
    |> put_resp_header("Content-Disposition", "filename=\"#{filename}\"")
  end

  defp header_for_format("jpg"), do: "image/jpg"
  defp header_for_format("png"), do: "image/png"

  defp needs_to_verify_urls do
    Config.verify_urls && Config.secret
  end
end
