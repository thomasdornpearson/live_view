defmodule LiveViewWeb.UiChannel do
  use Phoenix.Channel
  require Logger

  use Task
  use Tesla

  plug Tesla.Middleware.BaseUrl, "http://localhost:4001"
  plug Tesla.Middleware.JSON

  @query_user_url "/api/v1/user/queryusers?username="
  defp halt do
    Process.exit(self(), :normal)
  end

  def join("ui:default", %{"token" => token, "username" => username}, socket) do
    IO.puts("Frontend joined 2")
    if token != nil do
      with {:ok, %{"access" => access_level, "iat" => time, "username" => token_username}} <- LiveViewWeb.JwtAuthToken.verify_and_validate(token) do
        socket = socket |> assign(:token, token) |> assign(:username, username)
        if access_level == "standard" && username == token_username do
          socket = socket |> assign(:token, token) |> assign(:username, username)
          {:ok, socket}
        else
          halt()
        end
      else
        {:error, reason} -> IO.inspect(reason)
      end
    else
      halt()
    end
  end

  def join("ui:default", %{"accessToken" => token}, socket) do
    IO.puts("Backend Joined")
    socket = socket |> assign(:token, token)
    send(self, :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    push(socket, "heartBeatDownstream", 0)
    {:noreply, socket}
  end

  def handle_in("heartBeatUpstream", msg, socket) do
    Process.sleep(10000)
    push(socket, "heartBeatDownstream", msg + 1)
    {:noreply, socket}
  end

  def handle_in("ui:uploadProgress:" <> username, payload, socket) do
    IO.puts(username)
    broadcast!(socket, "ui:uploadProgress:" <> username, payload)
    Logger.info ":: Broadcaster receive a message!::"
    {:reply, {:success, %{"hello" => "world"}}, socket}
  end

  def handle_in("ui:commentPosted:" <> filename, payload, socket) do
    Logger.info "::Receved a Comment update::"
    broadcast!(socket, "ui:getNewComments:" <> filename, payload)
    {:noreply, socket}
  end

  def handle_in("ui:getAccess:" <> username, payload, socket) do
    Logger.info "::Receved a getAccess::"
#    search = payload["event"] |> String.downcase
#    result = case get(@query_user_url <> search) do
#      {:ok, response} ->
#        if response.body["success"] === true do
#          response.body["queryUsers"]["data"] |> Enum.map(fn x -> %{"username" => x["username"]} end)
#        else
#          IO.puts("error")
#          []
#        end
#      {:error, reason} -> Process.exit(self(), :normal)
#    end
#    {:reply, {:ok,  result}, socket}


    if payload["event"] != nil do
      search = payload["event"] |> String.downcase
      select = [{"username", 1}, {"limit", 10}]
      query = %{"username" => %{"$regex" => search, "$options" => "i"}}
      result = Mongo.find(:mongo, "users", query, select) |> Enum.to_list |> Enum.map(fn x -> %{"username" => x["username"]} end)
      {:reply, {:ok, result}, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_in("ui:getCategories:" <> username, payload, socket) do
    Logger.info "::Receved a getAccess::"
    #    search = payload["event"] |> String.downcase
    #    result = case get(@query_user_url <> search) do
    #      {:ok, response} ->2
    #        if response.body["success"] === true do
    #          response.body["queryUsers"]["data"] |> Enum.map(fn x -> %{"username" => x["username"]} end)
    #        else
    #          IO.puts("error")
    #          []
    #        end
    #      {:error, reason} -> Process.exit(self(), :normal)
    #    end
    #    {:reply, {:ok,  result}, socket}


    if payload["event"] != nil do
      search = payload["event"] |> String.downcase
      select = [{"username", 1}, {"limit", 10}]
      query = %{"name" => %{"$regex" => search, "$options" => "i"}}
      result = Mongo.find(:mongo, "categories", query, select) |> Enum.to_list |> Enum.map(fn x -> x["name"] end) |> IO.inspect
      {:reply, {:ok, result}, socket}
    else
      {:noreply, socket}
    end
  end
end
