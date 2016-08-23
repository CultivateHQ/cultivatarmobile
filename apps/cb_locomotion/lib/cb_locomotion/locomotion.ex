defmodule CbLocomotion.Locomotion do
  @moduledoc """
  The main interface for moving the robot. Interacts with the two stepper motors
  to move the robot forward, back, left, right, stop, and set the rate at which
  both motors turn.
  """

  @name __MODULE__
  use GenServer
  alias CbLocomotion.StepperMotor

  def start_link do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  ### API
  def set_step_rate(step_rate) do
    GenServer.call(@name, {:set_step_rate, step_rate})
  end

  def forward do
    GenServer.call(@name, :forward)
  end

  def reverse do
    GenServer.call(@name, :reverse)
  end

  def stop do
    GenServer.call(@name, :stop)
  end

  def turn_right do
    GenServer.call(@name, :turn_right)
  end

  def turn_left do
    GenServer.call(@name, :turn_left)
  end

  ## Callbacks

  def init(_) do
    {:ok, []}
  end


  def handle_call({:set_step_rate, step_rate}, _from, state) do
    :left_stepper |> StepperMotor.set_step_rate(step_rate)
    :right_stepper |> StepperMotor.set_step_rate(step_rate)

    {:reply, :ok, state}
  end

  def handle_call(:forward, _from, state) do
    set_direction(:back, :forward)
    {:reply, :ok, state}
  end

  def handle_call(:reverse, _from, state) do
    set_direction(:forward, :back)
    {:reply, :ok, state}
  end

  def handle_call(:stop, _from, state) do
    set_direction(:neutral, :neutral)
    {:reply, :ok, state}
  end

  def handle_call(:turn_left, _from, state) do
    set_direction(:forward, :forward)
    {:reply, :ok, state}
  end

  def handle_call(:turn_right, _from, state) do
    set_direction(:back, :back)
    {:reply, :ok, state}
  end

  defp set_direction(left, right) do
    :left_stepper |> StepperMotor.set_direction(left)
    :right_stepper |> StepperMotor.set_direction(right)
  end
end
