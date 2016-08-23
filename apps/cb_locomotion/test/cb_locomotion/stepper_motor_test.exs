defmodule CbLocomotion.StepperMotorTest do
  use ExUnit.Case
  alias CbLocomotion.StepperMotor

  @pins [30, 31, 32, 33]

  setup do
    {:ok, pid} = StepperMotor.start_link(@pins)
    :timer.sleep(1)
    {:ok, pid: pid}
  end

  test "initialisation", %{pid: pid} do
    state = pid |> StepperMotor.state
    assert state.pins == expected_pin_pids
    assert state.direction == :neutral
    assert state.position == 0
    assert state.timer_ref == nil
    assert state.gear == :low
  end

  test "setting_gear", %{pid: pid} do
    pid |> StepperMotor.set_high_gear
    assert StepperMotor.state(pid).gear == :high
    pid |> StepperMotor.set_low_gear
    assert StepperMotor.state(pid).gear == :low
  end

  test "setting a non-neutral direction sets the direction and a timer", %{pid: pid} do
    pid |> StepperMotor.set_direction(:forward)
    state = pid |> StepperMotor.state
    assert state.direction == :forward
    refute state.timer_ref == nil

    assert state.step_millis == Process.read_timer(state.timer_ref) # Will this ever fail due to a clock tick?
  end

  test "move back also works", %{pid: pid} do
    pid |> StepperMotor.set_direction(:back)
    state = pid |> StepperMotor.state
    assert state.direction == :back
    refute state.timer_ref == nil
  end

  test "neutral", %{pid: pid} do
    pid |> StepperMotor.set_direction(:back)

    previous_timer = StepperMotor.state(pid).timer_ref

    pid |> StepperMotor.set_direction(:neutral)

    state = pid |> StepperMotor.state
    assert state.direction == :neutral
    assert state.timer_ref == nil

    assert Process.read_timer(previous_timer) == false
  end


  test "changing timer interval in neutral does little", %{pid: pid} do
    pid |> StepperMotor.set_step_rate(50)

    state = pid |> StepperMotor.state
    assert state.direction == :neutral
    assert state.timer_ref == nil
    assert state.step_millis == 50
  end

  test "changing timer interval when moving", %{pid: pid} do
    pid |> StepperMotor.set_direction(:forward)
    previous_timer_ref = StepperMotor.state(pid).timer_ref
    pid |> StepperMotor.set_step_rate(50)

    state = pid |> StepperMotor.state

    assert state.timer_ref
    assert state.step_millis == 50

    assert Process.read_timer(state.timer_ref) == 50
    assert Process.read_timer(previous_timer_ref) == false
  end

  test "stepping forward sets a new timer", %{pid: pid} do
    pid |> StepperMotor.set_step_rate(999999999999)
    pid |> StepperMotor.set_direction(:forward)
    previous_timer_ref = StepperMotor.state(pid).timer_ref

    send(pid, :step)
    :timer.sleep(1)

    state = pid |> StepperMotor.state

    assert state.position == 1
    refute state.timer_ref == previous_timer_ref

    assert state.step_millis - Process.read_timer(state.timer_ref) < 5

  end

  test "cycling forward", %{pid: pid} do
    pid |> StepperMotor.set_step_rate(999999999999)
    pid |> StepperMotor.set_direction(:forward)
    (1..7) |> Enum.each(fn i ->
      send(pid, :step)
      :timer.sleep(1)
      assert StepperMotor.state(pid).position == i
    end)

    send(pid, :step)
    :timer.sleep(1)
    assert StepperMotor.state(pid).position == 0

    assert Gpio.pin_state_log(:gpio_30) == [0, 0, 0, 0, 0, 1, 1, 1, 0]
    assert Gpio.pin_state_log(:gpio_33) == [1, 1, 0, 0, 0, 0, 0, 1, 1]
  end


  test "cycling back", %{pid: pid} do
    pid |> StepperMotor.set_step_rate(999999999999)
    pid |> StepperMotor.set_direction(:back)
    (7..0) |> Enum.each(fn i ->
      send(pid, :step)
      :timer.sleep(1)
      assert StepperMotor.state(pid).position == i
    end)

    assert Gpio.pin_state_log(:gpio_30) == [0, 0, 0, 0, 0, 1, 1, 1, 0] |> Enum.reverse
    assert Gpio.pin_state_log(:gpio_33) == [1, 1, 0, 0, 0, 0, 0, 1, 1] |> Enum.reverse
  end

  test "cycling forward in high", %{pid: pid} do
    pid |> StepperMotor.set_step_rate(999999999999)
    pid |> StepperMotor.set_high_gear
    pid |> StepperMotor.set_direction(:forward)
    [2, 4, 6, 0] |> Enum.each(fn i ->
      send(pid, :step)
      :timer.sleep(1)
      assert StepperMotor.state(pid).position == i
    end)
  end

  test "cycling back in high", %{pid: pid} do
    pid |> StepperMotor.set_step_rate(999999999999)
    pid |> StepperMotor.set_high_gear
    pid |> StepperMotor.set_direction(:back)
    [6, 4, 2, 0, 6] |> Enum.each(fn i ->
      send(pid, :step)
      :timer.sleep(1)
      assert StepperMotor.state(pid).position == i
    end)
  end

  defp expected_pin_pids do
    @pins
    |> Enum.map(&("gpio_#{&1}"))
    |> Enum.map(&String.to_atom/1)
    |> Enum.map(&Process.whereis/1)
  end
end
