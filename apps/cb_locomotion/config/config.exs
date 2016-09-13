use Mix.Config

config :cb_locomotion, :steppers, [right: [21, 20, 16, 12],
                        left: [26, 19, 13, 6]]
config :cb_locomotion, :gpio_pins_to_test, 2..27
