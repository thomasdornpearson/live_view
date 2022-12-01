defmodule LiveView.TransactionAgent do
  use Agent

  defp loop(txHash) do
    getTransactionConfirm(txHash)
    Process.sleep(:timer.seconds(3))
    Agent.stop(self)
    loop(txHash)
  end

  defp getTransactionConfirm(txHash) do
    IO.puts("getting info")
  end

  def start_link(txHash, process_name) do
    Agent.start_link(fn -> loop(txHash) end, name: process_name)
  end


end
