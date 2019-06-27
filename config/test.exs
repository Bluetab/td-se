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
  data_structure_index: "data_structure_test",
  business_concept_index: "business_concept_test",
  ingest_index: "ingest_test"

config :td_se, permission_resolver: TdSe.Permissions.MockPermissionResolver
config :td_cache, redis_host: "redis"
