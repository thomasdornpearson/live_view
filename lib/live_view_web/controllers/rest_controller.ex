defmodule LiveViewWeb.RestController do
  alias Mongo.GridFs.Bucket
  use LiveViewWeb, :controller
  def test(conn, params) do
    params |> IO.inspect
    userQuery = %{
      "username" => "thomasdorn@dornhost.com"
    }
#    json(conn, userQuery)
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(200, Jason.encode!(userQuery))
  end

  def upload_file(conn, params) do
#    content_length = Plug.Conn.get_req_header(conn, "content-length") |> List.first
#    {myInt, _} = :string.to_integer(to_char_list(content_length))
#    {:ok, body, conn} = Plug.Conn.read_body(conn, length: myInt)
#
#    body |> IO.inspect
#    IO.inspect(params)
    conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(conn.assigns.current_user))
  end




  def get_file(conn, params) do
    result = Mongo.find(:mongo, "mediafiles", %{"filename" => "3b655144-0820-4294-91ed-96e86b709f50"}, limit: 1)
             |> Enum.to_list
             |> List.first
    {:ok, stream} = Mongo.GridFs.Download.open_download_stream(%Bucket{topology_pid: :mongo, opts: [], name: "files"}, result["attachmentId"])
    stream
    |> Enum.into(
         conn
         |> send_chunked(200)
       )
  end

  def start_monitor_eth_address_for_deposit(conn, params) do

  end

  defp file_count(array) do
    images = Enum.count(array, fn x -> String.contains?(x, "image") end)
    videos = Enum.count(array, &(String.contains?(&1, "video")))
    %{"videosCount": videos, "imagesCount": images}
  end

  defp formatter(data, class_name) do
    %{"success"  => true, class_name => %{"data" => data}}
  end

  def get_categories(conn, _params) do
    Mongo.find(:mongo, "categories", %{}) |> Enum.to_list |> Enum.map(fn x-> x["name"] end) |>
    then(fn x ->
      conn |> Plug.Conn.put_resp_content_type("application/json")
           |> Plug.Conn.send_resp(200, Jason.encode!(formatter(x, "categories")))
    end)
  end

  def get_user_list(conn, _params) do
    Mongo.aggregate(:mongo, "users", [
      %{"$match" => %{}},
      %{"$project" => %{"username" => 1.0}},
      %{"$lookup" => %{"from" => "mediafiles", "localField" => "username","foreignField" => "username", "as" => "mediafiles"}},
      %{"$project" => %{"mediafiles.mimeType"=>1.0,"username"=>"$username"}}
    ]) |> Enum.to_list |> Enum.map(fn x ->
      %{"username" => x["username"],
        "fileTypes" => Enum.map(x["mediafiles"], fn y -> y["mimeType"] end)
       } end) |> Enum.map(fn x ->
          %{
            "username" => x["username"],
            "files" => file_count(x["fileTypes"])
          }
        end) |> then(fn x->
              conn |> Plug.Conn.put_resp_content_type("application/json")
              |> Plug.Conn.send_resp(200, Jason.encode!(formatter(x, "files")))
    end)
  end


  def send_upload_data(conn, params) do
    username = params["username"]
    bytes = params["bytes"]
    LiveViewWeb.Endpoint.broadcast("ui:default", "ui:uploadProgress:" <> username , bytes)
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(200, Jason.encode!(params))
  end

end
