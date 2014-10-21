defmodule HttpAdapter do
  def fetch(path) do
    %HTTPoison.Response{body: image_binary, status_code: 200} = HTTPoison.get!(host <> "/" <> path)
    image_binary
  end

  defp host do
    System.get_env("HTTP_HOST")
  end
end
