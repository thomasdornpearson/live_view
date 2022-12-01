defmodule LiveViewWeb.Plug.AuthenticateJwt do
  import Plug.Conn
  require Logger

  def init(opts) do
    opts
  end

  def first_match(collection, key) do
    Enum.find(collection, fn(element) ->
      Keyword.get()
    end)
  end

  def call(conn, _opts) do
    token = get_req_header(conn, "token") |> Enum.to_list |> List.first
    with {:ok, %{"access" => access_level, "iat" => time, "username" => token_username}} <- LiveViewWeb.JwtAuthToken.verify_and_validate(token)
    do
      Mongo.find(:mongo, "users", %{"token" => token}, limit: 1) |> Enum.to_list |> List.first |> then(fn user -> conn |> assign(:current_user, user) end)
    else
      error -> conn |> Plug.Conn.put_resp_content_type("application/json") |> Plug.Conn.send_resp(200, Jason.encode!(%{"success" => false, "message" => "invalid token"})) |> halt()
    end
  end

end
