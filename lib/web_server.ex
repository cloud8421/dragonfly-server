defmodule WebServer do
  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    WebRouter.call(conn, WebRouter.init([]))
  end
end
