defmodule Runner do
  def process(job) do
    Decoder.decode(job)
    |> Steps.to_command
  end
end
