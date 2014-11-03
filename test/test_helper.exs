ExUnit.start()

defmodule Fixtures do
  def sample_image do
    {:ok, data} = File.read("./test/fixtures/sample.jpg")
    data
  end

  def sample_transformed_image do
    {:ok, data} = File.read("./test/fixtures/transformed.png")
    data
  end
end
