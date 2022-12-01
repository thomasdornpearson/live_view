defmodule LiveView.BalanceTransactions do
  use Task
  use Phoenix.Channel
  use Tesla

  plug Tesla.Middleware.BaseUrl, "http://localhost:4001"
  plug Tesla.Middleware.JSON

  import LiveView.TransactionAgent
  require Logger

  defp hex_to_integer(hex) do
    case hex do
      "0x" <> hex -> {:ok, String.to_integer(hex, 16)}
      _ -> {:error, :invalid_hex_string}
    end
  rescue
    ArgumentError ->
      {:error, :invalid_hex_string}
  end

  defp integer_to_hex(i) do
    case i do
      i when i < 0 -> {:error, :negative_integer}
      i -> {:ok, "0x" <> Integer.to_string(i, 16)}
    end
  rescue
    ArgumentError ->
      {:error, :non_integer}
  end

  defp get_tx_hash_block_account({starting_block, block_number}, account_number) do
    {:ok, block} = Ethereumex.HttpClient.eth_get_block_by_number(block_number, true)
    transactions = Map.get(block,"transactions")
    to_accounts = Enum.map(transactions, fn x -> x["to"] end)
    if Enum.member?(to_accounts, account_number) do
      transaction = Enum.filter(transactions,
      fn x ->
        {:ok, value} = hex_to_integer(x["value"])
          x["to"] === account_number and value > 0.00
      end)
      {:ok, transaction}
    else
      {:ok, blockInt} = hex_to_integer(block_number)
      next_block_to_search = blockInt - 1
      {:ok, block_hex_next} = integer_to_hex(next_block_to_search);
      {:ok, startin_block_int} = hex_to_integer(starting_block)
      if next_block_to_search + 10 === startin_block_int do
        {:false}
      else
        get_tx_hash_block_account({starting_block, block_hex_next}, account_number)
      end
    end
  end

  defp process_update(transaction, amount_to_confirm, account_number) do
    IO.inspect(account_number)
    IO.inspect(transaction)
    IO.inspect(amount_to_confirm)
    IO.puts "FOUND TX"
    Process.exit(self(), :normal)
  end

  def loop(account_number, amount_to_confirm) do
    IO.puts("looked for: " <> account_number)
    {:ok, block_number} = Ethereumex.HttpClient.eth_block_number
    case get_tx_hash_block_account({block_number, block_number}, account_number) do
      {:ok, transaction} -> process_update(transaction, amount_to_confirm, account_number)
      {:false} -> get_tx_hash_block_account({block_number, block_number}, account_number)
    end
    Process.sleep(:timer.seconds(5))
    loop(account_number, amount_to_confirm)
  end
end
