use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :td_se, TdSeWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :td_se, :elasticsearch,
  search_service: TdSe.Search.MockSearch,
  es_host: "localhost",
  es_port: 9200,
  type_name: "doc"
