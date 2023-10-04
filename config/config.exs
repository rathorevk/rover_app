import Config

config :logger, :console,
  format: "[$metadata][$level] $message\n",
  metadata: [:file]

config :rover_app, grid_size: [5, 5]

import_config "#{Mix.env()}.exs"
