defmodule Cb.Bot do
  use Slacker
  use Slacker.Matcher

  match ~r/^c(ultivate)?? help/i, :help
  match ~r/^c(ultivate)?? hi/i, :say_hello
  match ~r/^c(ultivate)?? where are you/i, :show_inet_addr
  match ~r/^c(ultivate)?? (forward|reverse|back|left|right|stop)/i, :control
  match ~r/^c(cultivate)?? step (\d+)/i, :set_step_rate

  match ~r/^c(ultivate)?? pin test\s*$/i, :start_pin_test
  match ~r/^c(ultivate)?? pin test end/i, :stop_pin_test

  alias CbLocomotion.Locomotion
  alias CbLocomotion.PinTest

  def say_hello(_bot, msg, _ \\ nil) do
    say self, msg["channel"], "¡Hola!"
  end

  def help(_bot, msg, _ \\ nil) do
    say self, msg["channel"], """
    Hello, I am the controller. Here is what you do.

    `cultivate help`: show this message.
    `cultivate hi`: say hello.
    `cultivate where are you?`: display the IP addresses to which I'm connected.
    `cultivate forward`: drive forward.
    `cultivate reverse`: reverse.
    `cultivate back`: reverse.
    `cultivate left`: turn left.
    `cultivate right`: turn right.
    `cultivate stop`: stop.
    `cultivate step (number)`: set the rate at which the stepper motors turn. The maximum is 0 (and pretty slow), and is also the default. 50 is incredibly slow.
    `cultivate pin test`: flash all the GPIO pins every 0.5 seconds. This won't don't much with the motors but is handy for testing your GPIO header soldering.
    `cultivate pin test end`: stop all that annoying GPIO flashing.

    It is possible that you will get fed up with our brand placement. You can just write `c` instead of `cultivate`. (I do.)
    """
  end

  def show_inet_addr(_bot, msg, _ \\ nil) do
    case :inet.getifaddrs do
      {:ok, addrs} ->
        say self, msg["channel"], addrs_to_msg(addrs)
      {:error, posix} ->
        say self, msg["channel"], "That did not work out #{inspect(posix)}"
    end
  end

  def control(bot, msg, _, direction), do: control(bot, msg, direction)
  def control(_bot, msg, "forward") do
    Locomotion.forward
    say self, msg["channel"], "Forward!"
  end
  def control(_bot, msg, "reverse") do
    Locomotion.reverse
    say self, msg["channel"], "Reverse!"
  end
  def control(bot, msg, "back"), do: control(bot, msg, "reverse")
  def control(_bot, msg, "left") do
    Locomotion.turn_left
    say self, msg["channel"], "Left!"
  end
  def control(_bot, msg, "right") do
    Locomotion.turn_right
    say self, msg["channel"], "Right!"
  end
  def control(_bot, msg, "stop") do
    Locomotion.stop
    say self, msg["channel"], "Stop!"
  end

  def set_step_rate(_bot, msg, _ \\ nil, rate_str) do
    {rate, _} = Integer.parse(rate_str)
    Locomotion.set_step_rate(rate)
    say self, msg["channel"], "Stepping at #{rate}!"
  end


  def start_pin_test(_bot, msg, _ \\ nil) do
    PinTest.start_test
    say self, msg["channel"], "Testing pins!"
  end


  def stop_pin_test(_bot, msg, _ \\ nil) do
    PinTest.finish_test
    say self, msg["channel"], "Stopping pin test!"
  end

  defp addrs_to_msg(addrs) do
    addrs |> Enum.map(fn {iface, properties} -> { List.to_string(iface), Keyword.get(properties, :addr) } end)
    |> Enum.map(
      fn {iface, {a1,a2,a3,a4}} -> "#{iface}: #{a1}.#{a2}.#{a3}.#{a4}"
      _ -> nil end)
    |> Enum.filter(&(&1))
    |> Enum.join("\n")
  end
end
