defmodule LiveViewWeb.TransactionChannel do
  use Task
  use Phoenix.Channel
  use Tesla

  def join("transaction:default", %{"token" => token, "username" => username}, socket) do
    IO.puts("Frontend joined")
    socket = socket |> assign(:token, token) |> assign(:username, username)
    {:ok, socket}
  end

  def join("transaction:default", %{"accessToken" => token}, socket) do
    IO.puts("Backend Joined")
    socket = socket |> assign(:token, token)
    {:ok, %{"hello" => "world"} ,socket}
  end

  def handle_in("startMonitorTransactionHash", %{"transactionHash" => txHash, "username" => username}, socket) do
    Task.Supervisor.async_nolink(LiveView.TaskSupervisor, fn -> LiveView.Confirmations.loop(txHash, username) end)
    |> (&:timer.kill_after(:timer.minutes(30), &1.pid)).()
    {:noreply, socket}
  end

  def handle_in("startMonitorEthAddressForDeposit", %{"sendToEthAddress" => ethAddress, "username" => username, "amountToConfirm" => amountToConfirm}, socket) do
    Task.Supervisor.async_nolink(LiveView.TaskSupervisor, fn -> LiveView.BalanceTransactions.loop(ethAddress, username, amountToConfirm) end)
    |> (&:timer.kill_after(:timer.minutes(30), &1.pid)).()
    {:noreply, socket}
  end

  def handle_info({:DOWN, _,_,_,_}, socket) do
    {:noreply, socket}
  end

end
