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
    image_content = S3Client.fetch(path)
    opts = [in: image_content, out: :iodata]
    %Porcelain.Result{out: ["", data]} = Porcelain.shell(transformation_command, opts)
    data
  end
  defp execute(%{fetch: path}) do
    S3Client.fetch(path)
  end
end
