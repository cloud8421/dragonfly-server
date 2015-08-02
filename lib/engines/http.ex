defmodule Engines.Http do
  use GenServer
  use Timex
  import Config, only: [http_engine_host: 0,
                        aws_access_key_id: 0,
                        aws_secret_access_key: 0,
                        aws_region: 0,
                        sign_urls: 0]

  def fetch(url) do
    GenServer.call(__MODULE__, {:fetch, url}, Config.http_fetch_timeout)
  end

  def url_from_path(path) do
    url = http_engine_host <> "/" <> path
    if sign_urls do
      sign_url(url)
    else
      url
    end
  end

  ## Callbacks

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def handle_call({:fetch, url}, _from, state) do
    case remote_fetch(url) do
      success = {:ok, _data} ->
        {:reply, success, state, :hibernate}
      error = {:error, _reason} ->
        {:reply, error, state, :hibernate}
    end
  end

  ## Private

  defp sign_url(url, date \\ Date.now) do
    headers = HashDict.new
    AWSAuth.sign_url(aws_access_key_id, aws_secret_access_key,
                     "GET", url, aws_region, "s3", headers, date)
  end

  defp remote_fetch(url) do
    case HTTPoison.get!(url) do
      %HTTPoison.Response{body: image_binary, status_code: 200} ->
        {:ok, image_binary}
      _ -> {:error, :not_found}
    end
  end
end
