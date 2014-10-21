defmodule Job do
  def process(job) do
    job
    |> to_command
    |> execute
  end

  def to_command(job) do
    job
    |> PayloadDecoder.decode
    |> Steps.to_command
  end

  defp execute(%{fetch: path, shell: transformation_command}) do
    adapter.fetch(path)
    |> transform(transformation_command)
  end
  defp execute(%{fetch: path}) do
    adapter.fetch(path)
  end

  defp transform(image_data, transformation_command) do
    opts = [in: image_data, out: :iodata]
    result = Porcelain.shell(transformation_command, opts)
    IO.iodata_to_binary(result.out)
  end

  defp adapter do
    Application.get_env(:storage, :adapter)
  end
end
