defmodule Job do

  def process(job) do
    result = job
              |> deserialize
              |> execute
    case result do
      {format, {:error, error}} ->
        {format, {:error, error}}
      {format, {:ok, data}} ->
        DragonflyServer.cache_store.set(job, format, data)
        {format, {:ok, data}}
    end
  end

  def deserialize(job) do
    job
    |> Payload.decode
    |> Steps.deserialize
  end

  def expire(job) do
    DragonflyServer.cache_store.delete(job)
    job
    |> deserialize
    |> do_expire
  end

  def hash_from_payload(job) do
    job
    |> Payload.decode
    |> Crypt.hmac256(Config.secret)
    |> String.slice(0, 16)
  end

  def do_expire(%{fetch: url}) do
    Engines.Http.expire(url)
  end
  def do_expire(_), do: nil

  defp execute(steps = %Steps{convert: []}) do
    {steps.format, get_base_image(steps)}
  end
  defp execute(steps) do
    case get_base_image(steps) do
      {:ok, base_image} -> {steps.format, {:ok, base_image
                                                |> transform(steps.convert)}}
      error = {:error, error} -> error
    end
  end

  defp get_base_image(%Steps{fetch: url}) when is_binary(url) do
    fetch(url)
  end
  defp get_base_image(%Steps{file: path}) when is_binary(path) do
    file(path)
  end

  defp transform(image_data, transformation_command) do
    opts = [in: image_data, out: :iodata]
    case Porcelain.shell(transformation_command, opts) do
      %Porcelain.Result{status: 0, out: out} -> IO.iodata_to_binary(out)
      _ -> {:error, :transformation_failed}
    end
  end

  defp fetch(url), do: Engines.Http.fetch(url)
  defp file(path), do: Engines.Fs.fetch(path)
end
