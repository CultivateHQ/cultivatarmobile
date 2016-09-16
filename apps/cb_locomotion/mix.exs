defmodule CbLocomotion.Mixfile do
  use Mix.Project

  def project do
    [app: :cb_locomotion,
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
    [mod: {CbLocomotion, []},
     applications: applications(Mix.env)]
  end

  defp deps do
    [
      {:nerves, "~> 0.3.0"},
      {:elixir_ale, "~> 0.5.6", only: :prod},
      {:dummy_nerves, in_umbrella: true, only: [:dev, :test]}
    ]
  end

  defp applications(:prod), do: [:elixir_ale | general_apps]
  defp applications(_), do: general_apps

  defp general_apps, do: [:logger]
end
