defmodule Job do
  def process(job) do
    {format, data} = job
                      |> to_command
                      |> execute
    JobCacheStore.set(job, format, data)
    {format, data}
  end

  def to_command(job) do
    job
    |> PayloadDecoder.decode
    |> Steps.to_command
  end

  def expire(job) do
    JobCacheStore.delete(job)
    to_command(job)
    |> adapter.expire
  end

  defp execute(%{fetch: path, shell: transformation_command, format: format}) do
    data = adapter.fetch(path)
           |> transform(transformation_command)
    {format, data}
  end
  defp execute(%{fetch: path, format: format}) do
    {format, adapter.fetch(path)}
  end
  defp execute(%{fetch: path}) do
    {"jpg", adapter.fetch(path)}
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
