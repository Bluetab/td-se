use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :td_se, TdSeWeb.Endpoint,
  http: [port: 3300],
  server: true

# Print only warnings and errors during test
config :logger, level: :warn

config :td_se, :elasticsearch,
  search_service: TdSe.Search,
  es_host: "http://elastic",
  es_port: 9200,
  type_name: "doc"

config :td_se, :elastic_indexes,
  data_structure_alias: "structures_test_alias",
  business_concept_alias: "concepts_test_alias",
  ingest_alias: "ingests_test_alias"

config :td_se, permission_resolver: TdSe.Permissions.MockPermissionResolver
config :td_cache, redis_host: "redis"
