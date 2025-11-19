defmodule TdSeWeb.ElasticIndexJSONTest do
  use ExUnit.Case

  alias TdSeWeb.ElasticIndexJSON

  describe "index/1" do
    test "renders list of elastic indexes" do
      elastic_indexes = [
        %{alias: "structures", key: "structures-123", documents: 100, size: 1024}
      ]

      result = ElasticIndexJSON.index(%{elastic_indexes: elastic_indexes})

      assert %{data: data} = result
      assert is_list(data)
      assert length(data) == 1
    end
  end

  describe "show/1" do
    test "renders single elastic index" do
      elastic_index = %{
        alias: "structures",
        key: "structures-123",
        documents: 100,
        size: 1024
      }

      result = ElasticIndexJSON.show(%{elastic_index: elastic_index})

      assert %{data: data} = result
      assert data.alias == "structures"
      assert data.key == "structures-123"
      assert data.documents == 100
      assert data.size == 1024
    end
  end

  describe "data/1" do
    test "renders elastic index data" do
      elastic_index = %{
        alias: "structures",
        key: "structures-123",
        documents: 100,
        size: 1024
      }

      result = ElasticIndexJSON.data(elastic_index)

      assert result.alias == "structures"
      assert result.key == "structures-123"
      assert result.documents == 100
      assert result.size == 1024
    end
  end
end
