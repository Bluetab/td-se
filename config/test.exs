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
  es_host: "localhost",
  es_port: 9200,
  type_name: "doc"

config :td_se, :elastic_indexes,
  index_data_structure: "data_structure_test",
  index_bunsiness_concept: "business_concept_test"

config :td_se, permission_resolver: TdPerms.MockPermissionResolver
config :td_perms, redis_uri: "redis://localhost"
