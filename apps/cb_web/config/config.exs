# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config


config :cb_web, :cowboy_options, [port: 4000]

import_config "#{Mix.env}.exs"
