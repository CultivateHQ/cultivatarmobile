defmodule CbLocomotion do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      supervisor(Fw.Locomotion.LocomotionSupervisor, []),
    ]

    opts = [strategy: :one_for_one, name: CbLocomotion.Supervisor]
    Supervisor.start_link(children, opts)
  end

end