defmodule Fw.DistrubuteNode do
  use GenServer

  @name __MODULE__

  defmodule WifiEventHandler do
    use GenEvent

    def handle_event({:udhcpc, _, :bound, %{ipv4_address: address}}, state) do
      Fw.DistrubuteNode.ip_address_received(address)
      {:ok, state}
    end

    def handle_event(_event, state) do
      {:ok, state}
    end

  end

  @node_name "CultivatorMobile"

  def start_link do
    GenServer.start_link(__MODULE__, {}, name: @name)
  end


  def init(_) do
    %{status: 0} = Porcelain.shell("epmd -daemon")
    :ok = GenEvent.add_handler(Nerves.NetworkInterface.event_manager, WifiEventHandler, [])
    {:ok, []}
  end

  def ip_address_received(address) do
    GenServer.cast(@name, {:ip_address_received, address})
  end

  def handle_cast({:ip_address_received, address}, state) do
    Node.stop
    full_node_name = "#{@node_name}@#{address}" |> String.to_atom
    {:ok, _pid} = Node.start(full_node_name)
    {:noreply, state}
  end
end
