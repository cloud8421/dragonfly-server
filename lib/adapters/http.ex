defmodule Adapters do
  defmodule Http do
    def fetch(path) do
      %HTTPoison.Response{body: image_binary, status_code: 200} = HTTPoison.get!(host <> "/" <> path)
      image_binary
    end

    defp host do
      Application.get_env(:storage, :host)
    end
  end
end
