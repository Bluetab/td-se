defmodule TdSeWeb.SearchJSONTest do
  use ExUnit.Case

  alias TdSeWeb.SearchJSON

  describe "index/1" do
    test "renders search results grouped by index" do
      search_results = [
        %{
          "index" => "structures",
          "results" => [
            %{"id" => 1, "name" => "Structure 1", "_index" => "structures"},
            %{"id" => 2, "name" => "Structure 2", "_index" => "structures"}
          ]
        },
        %{
          "index" => "concepts",
          "results" => [%{"id" => 3, "name" => "Concept 1", "_index" => "concepts"}]
        }
      ]

      result = SearchJSON.index(%{search_results: search_results})

      assert %{data: data} = result
      assert is_list(data)
      assert length(data) == 2
      assert Enum.at(data, 0).index == "structures"
      assert length(Enum.at(data, 0).results) == 2
      assert Enum.at(data, 1).index == "concepts"
      assert length(Enum.at(data, 1).results) == 1
    end
  end

  describe "data/1" do
    test "renders search result data" do
      search_result = %{
        "id" => 1,
        "name" => "Test Item",
        "description" => "Test Description",
        "path" => "/test",
        "business_concept_id" => 123,
        "_index" => "structures"
      }

      result = SearchJSON.data(search_result)

      assert result["id"] == 1
      assert result["name"] == "Test Item"
      assert result["description"] == "Test Description"
      assert result["path"] == "/test"
      assert result["business_concept_id"] == 123
      assert result["index"] == "structures"
    end

    test "handles search result with minimal fields" do
      search_result = %{
        "id" => 1,
        "name" => "Test Item",
        "_index" => "structures"
      }

      result = SearchJSON.data(search_result)

      assert result["id"] == 1
      assert result["name"] == "Test Item"
      assert result["index"] == "structures"
      assert result["description"] == nil
      assert result["path"] == nil
      assert result["business_concept_id"] == nil
    end
  end
end
