use Mix.Config

config :cb_web, CbWeb.Endpoint,
  http: [port: 4001],
  # url: [host: "0.0.0.0", port: 80],
  check_origin: false,
  cache_static_manifest: "priv/static/manifest.json"

# Do not print debug messages in production
config :logger, level: :info

import_config "prod.secret.exs"
