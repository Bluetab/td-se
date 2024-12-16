import Config

config :td_cluster, groups: [:se]

if config_env() == :prod do
  config :td_core, TdCore.Auth.Guardian, secret_key: System.fetch_env!("GUARDIAN_SECRET_KEY")

  config :td_cache,
    redis_host: System.fetch_env!("REDIS_HOST"),
    port: System.get_env("REDIS_PORT", "6379") |> String.to_integer(),
    password: System.get_env("REDIS_PASSWORD")

  config :td_core, TdCore.Search.Cluster, url: System.fetch_env!("ES_URL")

  with username when not is_nil(username) <- System.get_env("ES_USERNAME"),
       password when not is_nil(password) <- System.get_env("ES_PASSWORD") do
    config :td_core, TdCore.Search.Cluster,
      username: username,
      password: password
  end

  with api_key when not is_nil(api_key) <- System.get_env("ES_API_KEY") do
    config :td_core, TdCore.Search.Cluster,
      default_headers: [{"Authorization", "ApiKey #{api_key}"}]
  end

  optional_ssl_options =
    case System.get_env("ES_SSL") do
      "true" ->
        cacertfile =
          case System.get_env("ES_SSL_CACERTFILE", "generated") do
            "generated" -> :certifi.cacertfile()
            file -> file
          end

        [
          ssl: [
            cacertfile: cacertfile,
            verify:
              System.get_env("ES_SSL_VERIFY", "verify_none")
              |> String.downcase()
              |> String.to_atom()
          ]
        ]

      _ ->
        []
    end

  elastic_default_options =
    [
      timeout: System.get_env("ES_TIMEOUT", "5000") |> String.to_integer(),
      recv_timeout: System.get_env("ES_RECV_TIMEOUT", "40000") |> String.to_integer()
    ] ++ optional_ssl_options

  config :td_core, TdCore.Search.Cluster, default_options: elastic_default_options
end
