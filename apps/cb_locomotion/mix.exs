defmodule CbLocomotion.Mixfile do
  use Mix.Project

  @target System.get_env("NERVES_TARGET") || "rpi"

  def project do
    [app: :cb_locomotion,
     version: "0.0.1",
     target: @target,
     archives: [nerves_bootstrap: "~> 0.1.4"],
     deps_path: "../../deps",
     build_path: "../../_build/#{@target}",
     config_path: "../../config/config.exs",
     lockfile: "../../mix.lock",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(Mix.env),
     deps: deps ++ system(@target, Mix.env)]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {CbLocomotion, []},
     applications: applications(Mix.env)]
  end

  def deps do
    [
      {:nerves, "~> 0.3.0"},
      {:elixir_ale, "~> 0.5.6", only: :prod},
      {:dummy_nerves, in_umbrella: true, only: [:dev, :test]}
    ]
  end

  def system(target, :prod) do
    [{:"nerves_system_#{target}", ">= 0.0.0"}]
  end
  def system(_,_), do: []

  defp applications(:prod), do: [:elixir_ale | general_apps]
  defp applications(_), do: general_apps

  defp general_apps, do: [:logger]


  def aliases(:prod) do
    ["deps.precompile": ["nerves.precompile", "deps.precompile"],
     "deps.loadpaths":  ["deps.loadpaths", "nerves.loadpaths"]]
  end
  def aliases(_), do: []

end
