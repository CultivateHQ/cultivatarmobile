defmodule CbSlack do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # worker(Restarter, [{Cb.Bot, :start_link, [@slack_token, [name: :slack_bot]]}, 10_000, [name: :slack_bot_restarter]] ),
      worker(Cb.BotStarter, [])
    ]

    opts = [strategy: :one_for_one, name: CbSlack.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
