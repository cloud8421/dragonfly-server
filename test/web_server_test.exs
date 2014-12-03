defmodule WebServerTest do
  use ExUnit.Case
  use Plug.Test

  import Mock

  @opts WebServer.init([])
  @valid_url "/media/W1siZiIsImF0dGFjaG1lbnRzLzIwMTQxMDIwVDA4NTY1Ny03ODMxL1NhaW5zYnVyeSdzIFNwb29reSBTcGVha2VyIC0gaW1hZ2UgMS5qcGciXV0/sample.jpg"
  @admin_valid_url "admin/media/W1siZiIsImF0dGFjaG1lbnRzLzIwMTQxMDIwVDA4NTY1Ny03ODMxL1NhaW5zYnVyeSdzIFNwb29reSBTcGVha2VyIC0gaW1hZ2UgMS5qcGciXV0"
  @valid_etag "73f6e4aace13c086c25a4c0a674e0ee1195945b8fd0416cee239b88ad8ea9f42"

  setup do
    Application.put_env(:security, :verify_urls, false)
    :ok
  end

  test "it sends 404 when none matches" do
    req = conn(:get, "/foo")
          |> WebServer.call(@opts)
    assert req.state == :sent
    assert req.status == 404
  end

  test "it sends a well formed successful response" do
    with_mock Engines.Http, [:passthrough], [fetch: fn(_url) -> Fixtures.sample_image end] do
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
    with_mock Engines.Http, [:passthrough], [fetch: fn(_url) -> Fixtures.sample_image end] do
      req = conn(:get, @valid_url, nil, [{:headers, [{"if-none-match", @valid_etag}]}])
            |> WebServer.call(@opts)
      assert req.status == 304
    end
  end

  test "it supports urls with sha" do
    Application.put_env(:security, :verify_urls, true)
    Application.put_env(:security, :secret, "test-key")
    payload = "W1siZiIsImF0dGFjaG1lbnRzLzIwMTQxMDIwVDA4NTY1Ny03ODMxL1NhaW5zYnVyeSdzIFNwb29reSBTcGVha2VyIC0gaW1hZ2UgMS5qcGciXV0"
    hashed_job = Job.hash_from_payload(payload)
    url = @valid_url <> "?sha=" <> hashed_job
    invalid_url = @valid_url <> "?sha=foo"

    with_mock Engines.Http, [:passthrough], [fetch: fn(_url) -> Fixtures.sample_image end] do
      req = conn(:get, url)
            |> WebServer.call(@opts)
      assert req.status == 200

      req2 = conn(:get, invalid_url)
            |> WebServer.call(@opts)
      assert req2.status == 401
      assert nil == List.keyfind(req2.resp_headers, "ETag", 0)
    end
  end

  test "admin DELETE image" do
    req = conn(:delete, @admin_valid_url)
          |> WebServer.call(@opts)
    assert req.status == 202
  end

  test "admin GET image" do
    host = System.get_env("HTTP_HOST")
    expected_body = "{\"convert\":[],\"fetch\":\"#{host}/attachments/20141020T085657-7831/Sainsbury's Spooky Speaker - image 1.jpg\",\"file\":null,\"format\":\"jpg\"}"
    req = conn(:get, @admin_valid_url)
          |> WebServer.call(@opts)
    assert req.status == 200
    assert req.resp_body == expected_body
  end
end
