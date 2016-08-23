defmodule CbSlack.Mixfile do
  use Mix.Project

  def project do
    [app: :cb_slack,
     version: "0.1.0",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :restarter, :slacker, :websocket_client],
     mod: {CbSlack, []}]
  end

  defp deps do
    [
      {:websocket_client, github: "jeremyong/websocket_client"},
      {:cb_locomotion, in_umbrella: :true},
      {:restarter, "~> 0.1.0"},
      {:slacker, ">= 0.0.0"},
    ]
  end
end
