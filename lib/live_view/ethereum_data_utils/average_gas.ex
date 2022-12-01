defmodule LiveView.EthereumDataUtils.AverageGas do
  use GenServer, restart: :temporary
  @name :average_gas
  def start_link(_) do
    name = via_tuple(@name)
    GenServer.start_link(
        __MODULE__,
        [],
        name: name
      )
  end

  defp via_tuple(name) do
    LiveView.ProcessRegistry.via_tuple({__MODULE__, name})
  end

  @expiry_idle_timeout :timer.seconds(10)

  @impl GenServer
  def init(name) do
    {:ok, []}
  end

  def get_hello() do
    GenServer.call(via_tuple(@name), {:print})
  end

  # @impl GenServer
  # def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
  #   new_list = Todo.List.add_entry(todo_list, new_entry)
  #   Todo.Database.store(name, new_list)
  #   {:noreply, {name, new_list}, @expiry_idle_timeout}
  # end

  @impl GenServer
  def handle_call({:print},_,state) do
    Process.send(self(), {:info}, [:noconnect])
    new_state = [1 | state] |> IO.inspect
    {:reply, state, new_state}
  end

  @impl GenServer
  def handle_call({:print2},_,state) do
    Process.send(self(), {:info}, [:noconnect])
    new_state = [1 | state] |> IO.inspect
    {:reply, state, new_state}
  end


  @impl GenServer
  def handle_info({:info}, state) do
    # a |> IO.inspect
    # b |> IO.inspect
    IO.puts("called via other module")
    {:noreply, state}
  end
  # @impl GenServer
  # def handle_info(:timeout, {name, todo_list}) do
  #   IO.puts("Stopping to-do server for #{name}")
  #   {:stop, :normal, {name, todo_list}}
  # end
end
