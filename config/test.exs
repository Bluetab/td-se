use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :td_se, TdSeWeb.Endpoint, server: true

# Print only warnings and errors during test
config :logger, level: :warn

config :td_se, :indices,
  data_structure_alias: "structures_test_alias",
  business_concept_alias: "concepts_test_alias",
  ingest_alias: "ingests_test_alias"

config :td_se, permission_resolver: TdSe.Permissions.MockPermissionResolver
