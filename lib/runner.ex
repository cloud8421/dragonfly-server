defmodule Runner do
  def to_command(job) do
    job
    |> PayloadDecoder.decode
    |> Steps.to_command
  end

  def process(job) do
    job
    |> to_command
    |> execute
  end

  defp execute(%{fetch: path, shell: transformation_command}) do
    image_content = adapter.fetch(path)
    opts = [in: image_content, out: :iodata]
    result =  Porcelain.shell(transformation_command, opts)
    IO.iodata_to_binary(result.out)
  end
  defp execute(%{fetch: path}) do
    adapter.fetch(path)
  end

  defp adapter do
    Application.get_env(:storage, :adapter)
  end
end
