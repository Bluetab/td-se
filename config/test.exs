import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :td_se, TdSeWeb.Endpoint, server: true

# Print only warnings and errors during test
config :logger, level: :warn

config :td_se, :index_aliases,
  structures: "structures_test_alias",
  concepts: "concepts_test_alias",
  ingests: "ingests_test_alias"

config :td_se, TdSe.Search.Cluster, api: ElasticsearchMock

config :td_cache, redis_host: "redis", port: 6380
