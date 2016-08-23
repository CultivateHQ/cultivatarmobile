defmodule LoccomotionTest do
  use ExUnit.Case
  alias CbLocomotion.{StepperMotor, Locomotion}



  test "set step rate" do
    Locomotion.set_step_rate(20)
    assert StepperMotor.state(:right_stepper).step_millis == 20
    assert StepperMotor.state(:left_stepper).step_millis == 20
  end


  test "forward" do
    Locomotion.forward

    assert StepperMotor.state(:right_stepper).direction == :forward
    assert StepperMotor.state(:left_stepper).direction == :back
  end

  test "reverse" do
    Locomotion.reverse

    assert StepperMotor.state(:right_stepper).direction == :back
    assert StepperMotor.state(:left_stepper).direction == :forward
  end

  test "stop" do
    Locomotion.forward
    Locomotion.stop

    assert StepperMotor.state(:right_stepper).direction == :neutral
    assert StepperMotor.state(:left_stepper).direction == :neutral
  end

  test "turn right" do
    Locomotion.turn_right

    assert StepperMotor.state(:right_stepper).direction == :back
    assert StepperMotor.state(:left_stepper).direction == :back
  end

  test "turn left" do
    Locomotion.turn_left

    assert StepperMotor.state(:right_stepper).direction == :forward
    assert StepperMotor.state(:left_stepper).direction == :forward
  end
end
