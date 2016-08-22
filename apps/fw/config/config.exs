use Mix.Config

config :porcelain, driver: Porcelain.Driver.Basic

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Uncomment to use target specific configurations

# import_config "#{Mix.Project.config[:target]}.exs"
config :fw, :steppers, [right: [21, 20, 16, 12],
                               left: [26, 19, 13, 6]]


import_config "secret.exs"
