defmodule Fw.Ntp do
  require Logger
  use GenServer

  alias Porcelain.Result

  @moduledoc """
  Periodically run NTP

  NTPD options on a RPI2

  -d      Verbose
  -n      Do not daemonize
  -q      Quit after clock is set
  -N      Run at high priority
  -w      Do not set time (only query peers), implies -n
  -S PROG Run PROG after stepping time, stratum change, and every 11 mins
  -p PEER Obtain time from PEER (may be repeated)
  If -p is not given, 'server HOST' lines
  """

  defstruct time_set: false

  @name __MODULE__

  if :prod == Mix.env do
    @command "ntpd -n -q -p time.euro.apple.com"
  else
    @command "cat /dev/null"
  end


  @name __MODULE__

  def start_link do
     GenServer.start_link(__MODULE__, [], name: @name)
  end

  ## API
  def time_set? do
    GenServer.call(@name, :time_set?)
  end

  ## Callbacks
  def init(_) do
    synced = do_sync
    schedule_next_sync(synced)
    {:ok, %__MODULE__{}}
  end

  def handle_info(:sync_the_time, state) do
    success = do_sync
    schedule_next_sync(success)

    {:noreply, %{state | time_set: success}}
  end

  def handle_call(:time_set?, _from, state = %{time_set: time_set}) do
    {:reply, time_set, state}
  end

  defp schedule_next_sync(last_sync_successful) do
    Process.send_after(self, :sync_the_time, next_sync_time(last_sync_successful))
  end

  defp do_sync do
    case Porcelain.shell(@command) do
      %Result{status: 0} ->
        Logger.info "Successfully set the time over with NTP"
        true
      %Result{out: out, status: status} ->
        Logger.error "Failed to set the time with NTP:\n#{out}\n#{status |> inspect}"
        false
    end
  end

  defp next_sync_time(_last_sync_successful = true), do: :timer.minutes(30)
  defp next_sync_time(_last_sync_successful = false), do: :timer.seconds(2)
end
