defmodule Cb.BotStarter do
  use GenServer

  @compile_timestamp :calendar.universal_time |> :calendar.datetime_to_gregorian_seconds
  @name __MODULE__

  @slack_token Application.get_env(:cb_slack, :slack_token)
  @start_bot_mfa {Cb.Bot, :start_link, [@slack_token, [name: :cb_bot]]}

  @release_the_bot_recheck_time_delay :timer.seconds(1)
  @bot_restart_delay :timer.seconds(30)

  def start_link do
    GenServer.start_link(__MODULE__, {}, [name: @name])
  end

  def init(_) do
    send(self, :release_the_bot_if_time_set)
    {:ok, {}}
  end

  def handle_info(:release_the_bot_if_time_set, state) do
    release_the_bot(looks_like_time_is_set?)
    {:noreply, state}
  end


  def release_the_bot(true) do
    {:ok, _pid} = Restarter.start_link(@start_bot_mfa, @bot_restart_delay, [name: :cb_bot_restarter])
  end
  def release_the_bot(false) do
    Process.send_after(self, :release_the_bot_if_time_set, @release_the_bot_recheck_time_delay)
  end

  defp looks_like_time_is_set? do
    (:calendar.universal_time |> :calendar.datetime_to_gregorian_seconds) > @compile_timestamp
  end
end
