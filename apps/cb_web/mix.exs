defmodule CbWeb.Mixfile do
  use Mix.Project

  def project do
    [app: :cb_web,
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
    [applications: [:logger, :plug, :cowboy, :cb_locomotion],
     mod: {CbWeb, []}]
  end

  defp deps do
    [
      {:plug, ">= 0.0.0"},
      {:cowboy, ">= 0.0.0"},
      {:cb_locomotion, in_umbrella: true},
      # {:fw, in_umbrella: true},
    ]
  end
end
