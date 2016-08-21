defmodule Cb.Bot do
  use Slacker
  use Slacker.Matcher

  match ~r/^hi/i, :say_hello

  def say_hello(_bot, msg) do
    say self, msg["channel"], "¡Hola!"
  end
end
