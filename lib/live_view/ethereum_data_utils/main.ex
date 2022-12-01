defmodule LiveView.EthereumDataUtils.Main do
  use Task

  def start_link(_arg) do
    Task.start_link(&loop/0)
  end

  defp loop() do
    Process.sleep(:timer.seconds(1))
    # pid = LiveView.ProcessRegistry.via_tuple({LiveView.EthereumDataUtils.AverageGas, :average_gas})
    # GenServer.call(pid, {:print2})
    # # Process.send(pid, {:info}, [:noconnect])
    # LiveView.EthereumDataUtils.AverageGas.get_hello
    loop()
  end

end
