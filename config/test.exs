import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :td_se, TdSeWeb.Endpoint, server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Track all Plug compile-time dependencies
config :phoenix, :plug_init_mode, :runtime

config :td_se, :index_aliases,
  structures: "structures_test_alias",
  concepts: "concepts_test_alias",
  ingests: "ingests_test_alias"

config :td_core, TdCore.Search.Cluster, api: ElasticsearchMock

config :td_core, TdCore.Search.Cluster,
  aggregations: %{
    "domain" => 50,
    "user" => 50,
    "system" => 50
  }

config :td_cache, redis_host: "redis", port: 6380
