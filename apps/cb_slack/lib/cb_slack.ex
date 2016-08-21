defmodule CbSlack do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Cb.BotStarter, [])
    ]

    opts = [strategy: :one_for_one, name: CbSlack.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
