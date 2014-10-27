ExUnit.start()

defmodule Fixtures do
  def sample_image do
    {:ok, data} = File.read("./test/fixtures/sample.jpg")
    data
  end
end
