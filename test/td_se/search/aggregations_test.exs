defmodule TdSe.Search.AggregationsTest do
  use ExUnit.Case

  alias TdSe.Search.Aggregations

  describe "aggregation_terms/0" do
    test "returns the correct aggregation terms structure" do
      result = Aggregations.aggregation_terms()

      assert result == %{"_index" => %{terms: %{field: "_index"}}}
    end

    test "returns a map with _index key" do
      result = Aggregations.aggregation_terms()

      assert is_map(result)
      assert Map.has_key?(result, "_index")
    end

    test "returns terms configuration for _index field" do
      result = Aggregations.aggregation_terms()

      assert result["_index"] == %{terms: %{field: "_index"}}
    end
  end
end
