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
    |> Payload.decode
    |> Steps.to_command
  end

  def expire(job) do
    JobCacheStore.delete(job)
    job
    |> to_command
    |> do_expire
  end

  def do_expire(%{fetch: url}) do
    HttpEngine.expire(url)
  end
  def do_expire(_), do: nil

  def default_image_format, do: "jpg"

  defp execute(%{fetch: url, shell: transformation_command, format: format}) do
    data = fetch(url)
           |> transform(transformation_command)
    {format, data}
  end
  defp execute(%{fetch: url, format: format}) do
    {format, fetch(url)}
  end
  defp execute(%{fetch: url}) do
    {default_image_format, fetch(url)}
  end

  defp execute(%{file: path, shell: transformation_command, format: format}) do
    data = file(path)
           |> transform(transformation_command)
    {format, data}
  end
  defp execute(%{file: path, format: format}) do
    {format, file(path)}
  end
  defp execute(%{file: path}) do
    {default_image_format, file(path)}
  end

  defp transform(image_data, transformation_command) do
    opts = [in: image_data, out: :iodata]
    result = Porcelain.shell(transformation_command, opts)
    IO.iodata_to_binary(result.out)
  end

  defp fetch(url), do: HttpEngine.fetch(url)
  defp file(path), do: FsEngine.fetch(path)
end
