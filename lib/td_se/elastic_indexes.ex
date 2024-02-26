defmodule TdSe.ElasticIndexes do
  @moduledoc false
  alias TdCore.Search.Indexer

  defdelegate authorize(action, user, params), to: __MODULE__.Policy

  def list_elastic_indexes do
    Indexer.list_indexes()
  end

  def delete_elastic_index(elastic_index) do
    Indexer.delete_existing_index(elastic_index)
  end
end
