defmodule TdSeWeb.ElasticIndexJSON do
  def index(%{elastic_indexes: elastic_indexes}) do
    %{data: for(elastic_index <- elastic_indexes, do: data(elastic_index))}
  end

  def show(%{elastic_index: elastic_index}) do
    %{data: data(elastic_index)}
  end

  def data(elastic_index) do
    %{
      alias: elastic_index.alias,
      key: elastic_index.key,
      documents: elastic_index.documents,
      size: elastic_index.size
    }
  end
end
