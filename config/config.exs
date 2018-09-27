# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Hashing algorithm
config :td_se, hashing_module: Comeonin.Bcrypt

# Configures the endpoint
config :td_se, TdSeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "kOMRdB8CGJ31Wmi0gNOHIGJlF/ITlZZ8Uy0N/IJDpc5TKUU9W1O8j/sCa5y9iMqw",
  render_errors: [view: TdSeWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: TdSe.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :td_se, TdSe.Auth.Guardian,
  allowed_algos: ["HS512"], # optional
  issuer: "tdauth",
  ttl: { 1, :hours },
  secret_key: "SuperSecretTruedat"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
