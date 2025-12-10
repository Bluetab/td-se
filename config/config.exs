# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

# Environment
config :td_se, :env, Mix.env()

# Configures the endpoint
config :td_se, TdSeWeb.Endpoint,
  http: [port: 4006],
  url: [host: "localhost"],
  render_errors: [
    formats: [html: TdSeWeb.ErrorHTML, json: TdSeWeb.ErrorJSON],
    layout: false
  ]

# Configures Elixir's Logger
# set EX_LOGGER_FORMAT environment variable to override Elixir's Logger format
# (without the 'end of line' character)
# EX_LOGGER_FORMAT='$date $time [$level] $message'
config :logger, :console,
  format:
    (System.get_env("EX_LOGGER_FORMAT") || "$date\T$time\Z [$level] $metadata$message") <>
      "\n",
  level: :info,
  metadata: [:pid, :module],
  utc_log: true

# Configuration for Phoenix
config :phoenix, :json_library, Jason

config :td_core, TdCore.Auth.Guardian,
  allowed_algos: ["HS512"],
  issuer: "tdauth",
  aud: "truedat",
  ttl: {1, :hours},
  secret_key: "SuperSecretTruedat"

config :bodyguard, default_error: :forbidden

config :td_se, :index_aliases,
  structures: "structures",
  concepts: "concepts"

config :td_cache, redis_host: "redis"

# Import Elasticsearch config
import_config "elastic.exs"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
