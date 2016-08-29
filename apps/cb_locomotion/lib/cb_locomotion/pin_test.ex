defmodule CbLocomotion.PinTest do
  use GenServer

  @moduledoc """
  Flashes all the pins, for use in testing hardware (eg pin soldering)
  """

  @name __MODULE__
  @flash_rate 500
  @pins Application.get_env(:cb_locomotion, :gpio_pins_to_test)

  defstruct pins: [], currently_testing: false, pin_level: 0

  def start_link do
    GenServer.start_link(__MODULE__, {}, [name: @name])
  end

  def init(_) do
    pins = @pins
    |> Enum.map(fn i ->
      {:ok, pid} = Gpio.start_link(i, :output)
      pid
    end)
    {:ok, %__MODULE__{pins: pins}}
  end

  def start_test do
    GenServer.call(@name, :start_test)
  end

  def finish_test do
    GenServer.call(@name, :finish_test)
  end

  def handle_call(:start_test, _from, state = %{currently_testing: false}) do
    send(self, :flash)
    {:reply, :ok, %{state | currently_testing: true}}
  end
  def handle_call(:start_test, _from, state) do
    {:reply, :ok, state}
  end

  def handle_call(:finish_test, _from, state) do
    {:reply, :ok, %{state | currently_testing: false}}
  end

  def handle_info(:flash, state = %{currently_testing: true, pins: pins, pin_level: pin_level}) do
    Enum.each(pins, fn pin ->
      Gpio.write(pin, pin_level)
    end)
    next_pin_level = rem(pin_level + 1, 2)
    Process.send_after(self, :flash, @flash_rate)

    {:noreply, %{state | pin_level: next_pin_level}}
  end
  def handle_info(:flash, state), do: {:noreply, state}
end
