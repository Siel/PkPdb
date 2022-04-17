# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

import_config "secrets.exs"

config :web,
  ecto_repos: [Core.Repo],
  generators: [context_app: false]

config :web, :generators, context_app: :core

# Configures the endpoint
config :web, Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "u0/TOAyjucWO9PB3dUZlHjbnPWQPpXNc7qqY3dZ9m+wdpY6y2KiZhhEjYaeua5qz",
  render_errors: [view: Web.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Web.PubSub,
  live_view: [signing_salt: "vvyvQrVx"]

config :core, Core.Mailer,
  adapter: Swoosh.Adapters.SMTP,
  relay: "smtp.gmail.com",
  username: System.get_env("EMAIL_USER"),
  password: System.get_env("EMAIL_PASSWORD"),
  port: 587

config :phoenix, :json_library, Jason

# Configure Mix tasks and generators
config :core,
  ecto_repos: [Core.Repo]

# Sample configuration:
#
#     config :logger, :console,
#       level: :info,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]
#

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
# config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
