defmodule FsEngine do
  def fetch(path) do
    {:ok, image_binary} = File.read(base_path <> "/" <> path)
    image_binary
  end

  defp base_path do
    Application.get_env(:storage, :base_path)
  end
end
