defmodule Fw do
  use Application

  @wifi_opts Application.get_env(:fw, :wifi_opts)

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      worker(Nerves.InterimWiFi, ["wlan0", @wifi_opts], function: :setup),
      worker(Fw.Ntp, []),
      worker(Fw.DistrubuteNode, []),
    ]

    opts = [strategy: :one_for_one, name: Fw.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def connect do
    IO.inspect @wifi_opts
    Nerves.InterimWiFi.setup("wlan0", @wifi_opts)
  end

end
