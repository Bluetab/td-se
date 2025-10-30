defmodule TdSe.SearchTest do
  use ExUnit.Case

  import Mox

  alias TdSe.Search

  setup :verify_on_exit!

  describe "translate/1" do
    test "returns a map of aliases to indices" do
      ElasticsearchMock
      |> expect(:request, fn _, :get, "/_aliases", "", [] ->
        SearchHelpers.aliases_response()
      end)

      aliases = ["structures_test_alias", "concepts_test_alias", "foo"]

      assert Search.translate(aliases) == %{
               "concepts_test_alias" => "concepts_test",
               "structures_test_alias" => "structures_test"
             }
    end
  end

  describe "search/2" do
    test "searches with list of indices" do
      ElasticsearchMock
      |> expect(:request, fn _, :post, "/structures,concepts/_search", query, opts ->
        assert query == %{match_all: %{}}
        assert opts == [params: %{"track_total_hits" => "true"}]
        SearchHelpers.hits_response([%{"id" => 1, "_index" => "structures"}])
      end)

      indices = ["structures", "concepts"]
      query = %{match_all: %{}}

      result = Search.search(indices, query)

      assert [result_hit] = result.results
      assert result_hit["id"] == "1"
      assert result_hit["_index"] == "structures"
      assert result_hit["_source"] == %{"id" => 1}
      assert result.total == 1
    end

    test "searches with single index string" do
      ElasticsearchMock
      |> expect(:request, fn _, :post, "/structures/_search", query, opts ->
        assert query == %{match_all: %{}}
        assert opts == [params: %{"track_total_hits" => "true"}]
        SearchHelpers.hits_response([%{"id" => 2, "_index" => "structures"}])
      end)

      index = "structures"
      query = %{match_all: %{}}

      result = Search.search(index, query)

      assert [result_hit] = result.results
      assert result_hit["id"] == "2"
      assert result_hit["_index"] == "structures"
      assert result_hit["_source"] == %{"id" => 2}
      assert result.total == 1
    end

    test "searches with empty index string" do
      ElasticsearchMock
      |> expect(:request, fn _, :post, "/_search", query, opts ->
        assert query == %{match_all: %{}}
        assert opts == [params: %{"track_total_hits" => "true"}]
        SearchHelpers.hits_response([])
      end)

      index = ""
      query = %{match_all: %{}}

      result = Search.search(index, query)

      assert result.results == []
      assert result.total == 0
    end

    test "handles elasticsearch errors" do
      error = %Elasticsearch.Exception{
        message: "Connection refused",
        status: 500,
        line: 1,
        col: 1,
        type: "search_phase_execution_exception",
        query: %{match_all: %{}},
        raw: %{}
      }

      ElasticsearchMock
      |> expect(:request, fn _, :post, "/structures/_search", _, _ ->
        {:error, error}
      end)

      index = "structures"
      query = %{match_all: %{}}

      result = Search.search(index, query)

      assert result == error
    end

    test "handles elasticsearch errors in translate" do
      error = %Elasticsearch.Exception{
        message: "Connection refused",
        status: 500,
        line: 1,
        col: 1,
        type: "search_phase_execution_exception",
        query: %{match_all: %{}},
        raw: %{}
      }

      ElasticsearchMock
      |> expect(:request, fn _, :get, "/_aliases", "", [] ->
        {:error, error}
      end)

      aliases = ["structures_test_alias"]

      result = Search.translate(aliases)

      assert result == error
    end

    test "translates with empty aliases list" do
      ElasticsearchMock
      |> expect(:request, fn _, :get, "/_aliases", "", [] ->
        SearchHelpers.aliases_response()
      end)

      aliases = []

      result = Search.translate(aliases)

      assert result == %{}
    end

    test "translates filters out aliases with no actual aliases" do
      ElasticsearchMock
      |> expect(:request, fn _, :get, "/_aliases", "", [] ->
        {:ok,
         %{
           "structures_test" => %{"aliases" => %{}},
           "concepts_test" => %{"aliases" => %{"concepts_test_alias" => %{}}}
         }}
      end)

      aliases = ["structures_test_alias", "concepts_test_alias"]

      result = Search.translate(aliases)

      assert result == %{"concepts_test_alias" => "concepts_test"}
    end
  end
end
