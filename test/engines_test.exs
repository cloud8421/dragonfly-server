defmodule EginesTest do
  use ExUnit.Case

  import Mock

  test "can generate unsinged urls" do
    path = "attachments/20141020T085657-7831/Sainsbury's Spooky Speaker - image 1.jpg"
    unsigned_url = Engines.Http.url_from_path(path)

    expected = "#{System.get_env("HTTP_ENGINE_HOST")}/#{path}"

    assert(expected == unsigned_url)
  end

  test "can generate AWS4 signed urls" do
    path = "attachments/20141020T085657-7831/Sainsbury's Spooky Speaker - image 1.jpg"

    # force sign_urls to enabled
    with_mock Config, [:passthrough], [sign_urls: fn -> true end] do
      # freeze Date.now
      with_mock Timex.Date, [:passthrough], [now: fn -> Timex.Date.epoch end] do
        signed_url = Engines.Http.url_from_path(path)

        escaped_url = Regex.escape("#{System.get_env("HTTP_ENGINE_HOST")}/#{path}")
        expected = ~r/\A#{escaped_url}\?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=%2F19700101%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=19700101T000000Z&X-Amz-Expires=86400&X-Amz-Signature=\H{64}&X-Amz-SignedHeaders=host\Z/

        assert Regex.match?(expected, signed_url)
      end
    end
  end
end
