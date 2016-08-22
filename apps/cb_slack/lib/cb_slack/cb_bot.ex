defmodule Cb.Bot do
  use Slacker
  use Slacker.Matcher

  match ~r/^hi/i, :say_hello
  match ~r/where are you/i, :show_inet_addr

  def say_hello(_bot, msg) do
    say self, msg["channel"], "¡Hola!"
  end

  def show_inet_addr(_bot, msg) do
    case :inet.getifaddrs do
      {:ok, addrs} ->
        say self, msg["channel"], addrs_to_msg(addrs)
      {:error, posix} ->
        say self, msg["channel"], "That did not work out #{inspect(posix)}"
    end
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
