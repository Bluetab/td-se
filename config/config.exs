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
  render_errors: [view: TdSeWeb.ErrorView, accepts: ~w(json)]

# Configures Elixir's Logger
# set EX_LOGGER_FORMAT environment variable to override Elixir's Logger format
# (without the 'end of line' character)
# EX_LOGGER_FORMAT='$date $time [$level] $message'
config :logger, :console,
  format: (System.get_env("EX_LOGGER_FORMAT") || "$time $metadata[$level] $message") <> "\n",
  metadata: [:request_id]

# Configuration for Phoenix
config :phoenix, :json_library, Jason

config :td_se, TdSe.Auth.Guardian,
  # optional
  allowed_algos: ["HS512"],
  issuer: "tdauth",
  ttl: {1, :hours},
  secret_key: "SuperSecretTruedat"

config :td_se, permission_resolver: TdCache.Permissions

config :td_se, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [router: TdSeWeb.Router]
  }

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
