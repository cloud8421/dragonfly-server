defmodule Engines.Fs do
  def fetch(path) do
    abs_path(path) |> File.read
  end

  defp abs_path(path = "/" <> _rest), do: path
  defp abs_path(path), do: Config.fs_base_path <> "/" <> path
end
