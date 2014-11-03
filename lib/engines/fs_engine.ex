defmodule FsEngine do
  alias DragonflyServer.Config

  def fetch(path) do
    {:ok, image_binary} = abs_path(path) |> File.read
    image_binary
  end

  defp abs_path(path = "/" <> _rest), do: path
  defp abs_path(path), do: Config.fs_base_path <> "/" <> path
end
