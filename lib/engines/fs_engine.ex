defmodule FsEngine do
  def fetch(path), do: read_file(path)

  defp read_file(path = "/" <> _rest) do
    {:ok, image_binary} = File.read(path)
  end
  defp read_file(path) do
    {:ok, image_binary} = File.read(base_path <> "/" <> path)
    image_binary
  end

  defp base_path do
    Application.get_env(:storage, :base_path)
  end
end
