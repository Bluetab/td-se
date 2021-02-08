defmodule TdSe.Search.Cluster do
  @moduledoc "Elasticsearch cluster configuration for TdSe"

  use Elasticsearch.Cluster, otp_app: :td_se
end
