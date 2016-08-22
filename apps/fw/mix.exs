defmodule Fw.Mixfile do
  use Mix.Project

  @target System.get_env("NERVES_TARGET") || "rpi"

  def project do
    [app: :fw,
     version: "0.0.1",
     target: @target,
     archives: [nerves_bootstrap: "~> 0.1.4"],
     deps_path: "../../deps/",
     build_path: "../../_build/#{@target}",
     config_path: "../../config/config.exs",
     lockfile: "../../mix.lock",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     deps: deps ++ system(@target)]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Fw, []},
     applications: [:logger, :nerves_interim_wifi, :porcelain, :cb_slack, :elixir_ale, :runtime_tools]]
  end

  def deps do
    [{:nerves, "~> 0.3.0"}]
  end

  def system(target) do
    [
      {:"nerves_system_#{target}", ">= 0.0.0"},
      {:nerves_interim_wifi, "~> 0.0.2"},
      {:elixir_ale, "~> 0.5.6"},
      {:cb_slack, in_umbrella: true},
      {:porcelain, ">= 0.0.0" }
    ]
  end

  def aliases do
    ["deps.precompile": ["nerves.precompile", "deps.precompile"],
     "deps.loadpaths":  ["deps.loadpaths", "nerves.loadpaths"]]
  end

end
