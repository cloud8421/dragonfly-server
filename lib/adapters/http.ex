defmodule Adapters do
  defmodule Http do
    def fetch(path) do
      %HTTPoison.Response{body: image_binary, status_code: 200} = HTTPoison.get!(host <> "/" <> path)
      image_binary
    end

    defp host do
      System.get_env("S3_BASE_URL")
    end
  end
end
