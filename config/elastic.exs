use Mix.Config

config :td_se, TdSe.Search.Cluster,
  # Will be overridden by the `ES_URL` environment variable if set.
  url: "http://elastic:9200",
  api: Elasticsearch.API.HTTP,
  json_library: Jason,
  indexes: %{}
