defmodule FsEngine do
  def fetch(path) do
    {:ok, image_binary} = abs_path(path) |> File.read
    image_binary
  end

  defp abs_path(path = "/" <> _rest), do: path
  defp abs_path(path), do: base_path <> "/" <> path

  defp base_path do
    Application.get_env(:storage, :base_path)
  end
end
