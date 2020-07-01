import Config

config :td_se, TdSe.Auth.Guardian, secret_key: System.fetch_env!("GUARDIAN_SECRET_KEY")

config :td_se, :elasticsearch,
  es_host: System.fetch_env!("ES_HOST"),
  es_port: System.fetch_env!("ES_PORT")

config :td_cache,
  redis_host: System.fetch_env!("REDIS_HOST"),
  port: System.get_env("REDIS_PORT", "6379") |> String.to_integer()
