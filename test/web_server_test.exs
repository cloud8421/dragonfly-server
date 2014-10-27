defmodule WebServerTest do
  use ExUnit.Case
  use Plug.Test

  import Mock

  @opts WebServer.init([])
  @valid_url "/media/W1siZiIsImF0dGFjaG1lbnRzLzIwMTQxMDIwVDA4NTY1Ny03ODMxL1NhaW5zYnVyeSdzIFNwb29reSBTcGVha2VyIC0gaW1hZ2UgMS5qcGciXV0/sample.jpg"
  @admin_valid_url "admin/media/W1siZiIsImF0dGFjaG1lbnRzLzIwMTQxMDIwVDA4NTY1Ny03ODMxL1NhaW5zYnVyeSdzIFNwb29reSBTcGVha2VyIC0gaW1hZ2UgMS5qcGciXV0"
  @valid_etag "73f6e4aace13c086c25a4c0a674e0ee1195945b8fd0416cee239b88ad8ea9f42"

  test "it sends 404 when none matches" do
    req = conn(:get, "/foo")
          |> WebServer.call(@opts)
    assert req.state == :sent
    assert req.status == 404
  end

  test "it sends a well formed successful response" do
    with_mock HttpEngine, [:passthrough], [fetch: fn(_url) -> Fixtures.sample_image end] do
      req = conn(:get, @valid_url)
            |> WebServer.call(@opts)
      {"ETag", etag} = List.keyfind(req.resp_headers, "ETag", 0)
      {"cache-control", expire} = List.keyfind(req.resp_headers, "cache-control", 0)
      {"Content-Type", content_type} = List.keyfind(req.resp_headers, "Content-Type", 0)
      {"Content-Disposition", disp} = List.keyfind(req.resp_headers, "Content-Disposition", 0)
      assert req.status == 200
      assert etag == @valid_etag
      assert expire == "public, max-age=31536000"
      assert content_type = "image/jpg"
      assert disp == "filename=\"sample.jpg\""
    end
  end

  test "it correctly supports etags" do
    with_mock HttpEngine, [:passthrough], [fetch: fn(_url) -> Fixtures.sample_image end] do
      req = conn(:get, @valid_url, nil, [{:headers, [{"if-none-match", @valid_etag}]}])
            |> WebServer.call(@opts)
      assert req.status == 304
    end
  end

  test "it exposes an admin api" do
    req = conn(:delete, @admin_valid_url)
          |> WebServer.call(@opts)
    assert req.status == 202
  end
end
