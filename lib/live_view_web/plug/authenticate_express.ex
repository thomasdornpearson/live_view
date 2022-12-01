defmodule LiveViewWeb.Plug.AuthenticateExpress do
  import Plug.Conn
  require Logger

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    conn
  end

end