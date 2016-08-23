defmodule CbLocomotion.StepperMotor do
  use GenServer
  # alias Saxophone.StepperMotor

  defstruct pins: [], direction: :neutral, position: 0, step_millis: 0, timer_ref: nil, gear: :low

  @position_pin_values [
    [0, 0, 0, 1],
    [0, 0, 1, 1],
    [0, 0, 1, 0],
    [0, 1, 1, 0],
    [0, 1, 0, 0],
    [1, 1, 0, 0],
    [1, 0, 0, 0],
    [1, 0, 0, 1],
  ]

  @moduledoc """
  Represents the interface, via GPIO pins, to a stepper motor driver. Can adjust speed and direction.
  """

  def start_link(pin_ids = [_, _, _, _], opts \\ []) do
    GenServer.start_link(__MODULE__, pin_ids, opts)
  end


  ## API

  @doc """
  Set direction, either :forward, :back, or :neutral
  """
  def set_direction(pid, direction) do
    pid |> GenServer.call({:set_direction, direction})
  end

  @doc """
  Set the step rate in milliseconds
  """
  def set_step_rate(pid, new_step_rate) do
    pid |> GenServer.call({:set_step_rate, new_step_rate})
  end

  def state(pid) do
    pid |> GenServer.call(:get_state)
  end

  def set_low_gear(pid) do
    pid |> GenServer.call({:set_gear, :low})
  end

  def set_high_gear(pid) do
    pid |> GenServer.call({:set_gear, :high})
  end

  ## Callbacks
  def init(pin_ids) do
    gpio_pins = pin_ids |> Enum.map(fn pin ->
      {:ok, gpio_pid} = Gpio.start_link(pin, :output)
      gpio_pid
    end)

    send(self, :step)
    {:ok, %__MODULE__{pins: gpio_pins}}
  end

  def handle_call({:set_direction, direction}, _from, status) do
    timer_ref = schedule_next_step(direction, status.step_millis, status.timer_ref)
    {:reply, :ok, %{status | direction: direction, timer_ref: timer_ref}}
  end

  def handle_call({:set_step_rate, step_rate}, _from, status) do
    timer_ref = schedule_next_step(status.direction, step_rate, status.timer_ref)
    {:reply, :ok, %{status | step_millis: step_rate, timer_ref: timer_ref}}
  end

  def handle_call(:get_state, _from, status) do
    {:reply, status, status}
  end

  def handle_call({:set_gear, gear}, _from, status) do
    {:reply, :ok, %{status | gear: gear}}
  end

  def handle_info(:step, status = %{pins: pins,
                                    direction: direction,
                                    step_millis: step_millis,
                                    position: position,
                                    gear: gear}) do
    next_position = new_position(position, direction, step(gear))
    @position_pin_values
    |> Enum.at(next_position)
    |> Enum.zip(pins)
    |> Enum.each(fn {value, pin} ->
      pin |> Gpio.write(value)
    end)

    timer_ref = schedule_next_step(direction, step_millis)

    {:noreply, %{status | position: next_position, timer_ref: timer_ref}}
  end

  defp schedule_next_step(direction, step_millis, timer_ref) do
    cancel_timer(timer_ref)
    schedule_next_step(direction, step_millis)
  end

  defp schedule_next_step(:neutral, _step_millis), do: nil
  defp schedule_next_step(_direction, step_millis), do: Process.send_after(self, :step, step_millis)

  defp cancel_timer(:nil), do: false
  defp cancel_timer(timer_ref), do: Process.cancel_timer(timer_ref)

  defp new_position(position, :neutral, _) do
    position
  end

  @lint {~r/Refactor/, false}
  defp new_position(position, :forward, current_step) do
    (position + current_step) |> rem(8)
  end

  defp new_position(position, :back, current_step) do
    (8 + position - current_step) |> rem(8)
  end

  defp step(:low), do: 1
  defp step(:high), do: 2
end
