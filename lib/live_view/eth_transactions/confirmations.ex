defmodule LiveView.Confirmations do
  use Task
  use Phoenix.Channel
  use Tesla

  plug Tesla.Middleware.BaseUrl, "http://localhost:4001"
  plug Tesla.Middleware.JSON

  @confirmation_url "/api/v1/wallet/checkIfTransactionMined?txhash="

  require Logger

  defp handle_response({:false, tx}) do
    Logger.info "Tx not seen in blockchain " <> tx
  end

  defp handle_response(%{"data" => data}) do
    if data["confirmations"] > 2603 do
      IO.puts("got api data")
      # a request to node to update the database
      # broadcase to UI to refresh page show unblurred image and allow full access
      Process.exit(self(), :normal)
    end
  end

  def loop(txHash, username) do
    IO.puts("started wait for data")
    result = case get(@confirmation_url <> txHash) do
      {:ok, response} ->
        if response.body["success"] === true do
          response.body["checkIfTransactionMined"]
        else
          {:false, txHash}
        end
      # might want to add else case
      {:error, reason} -> Process.exit(self(), :normal)
    end
    handle_response(result)
    Process.sleep(:timer.seconds(30))
    loop(txHash, username)
  end

end
