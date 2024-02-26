defmodule TdSeWeb.SearchControllerTest do
  use ExUnit.Case
  use TdSeWeb.ConnCase

  import Mox

  @indices Application.compile_env(:td_se, :index_aliases)

  setup %{conn: conn} do
    [conn: put_req_header(conn, "accept", "application/json")]
  end

  setup :verify_on_exit!

  describe "Admin search" do
    @tag authentication: [role: "admin"]
    test "groups results by index alias", %{conn: conn} do
      ElasticsearchMock
      |> expect(:request, fn _, :get, "/_aliases", "", [] -> SearchHelpers.aliases_response() end)
      |> expect(:request, fn _, :post, _, _, opts ->
        assert opts == [params: %{"track_total_hits" => "true"}]

        SearchHelpers.hits_response([
          %{"_index" => "structures_test"},
          %{"_index" => "concepts_test"},
          %{"_index" => "ingests_test"},
          %{"_index" => "concepts_test"}
        ])
      end)

      assert %{"data" => data} =
               conn
               |> post(~p"/api/global_search")
               |> json_response(:ok)

      count_by_index =
        Map.new(data, fn %{"index" => index, "results" => results} ->
          {index, Enum.count(results)}
        end)

      assert count_by_index == %{
               "concepts_test_alias" => 2,
               "ingests_test_alias" => 1,
               "structures_test_alias" => 1
             }
    end

    @tag authentication: [role: "admin"]
    test "Searches all indices by default", %{conn: conn} do
      ElasticsearchMock
      |> expect(:request, fn _, :get, "/_aliases", "", [] -> SearchHelpers.aliases_response() end)
      |> expect(:request, fn _,
                             :post,
                             url,
                             %{aggs: aggs, from: 0, query: query, size: 100},
                             opts ->
        assert opts == [params: %{"track_total_hits" => "true"}]
        assert url == "/concepts_test_alias,ingests_test_alias,structures_test_alias/_search"
        assert aggs == %{"_index" => %{terms: %{field: "_index"}}}

        assert query == %{
                 bool: %{
                   minimum_should_match: 1,
                   should: [
                     %{
                       bool: %{
                         must: [
                           %{term: %{"_index" => "concepts_test"}},
                           %{term: %{"status" => "published"}}
                         ]
                       }
                     },
                     %{
                       bool: %{
                         must: [
                           %{term: %{"_index" => "ingests_test"}},
                           %{term: %{"status" => "published"}}
                         ]
                       }
                     },
                     %{
                       bool: %{
                         must: %{term: %{"_index" => "structures_test"}},
                         must_not: %{exists: %{field: "deleted_at"}}
                       }
                     }
                   ]
                 }
               }

        SearchHelpers.hits_response([%{"_index" => "concepts_test"}])
      end)

      assert %{"data" => _} =
               conn
               |> post(~p"/api/global_search")
               |> json_response(:ok)
    end

    @tag authentication: [role: "admin"]
    test "Search only specified indices", %{conn: conn} do
      ElasticsearchMock
      |> expect(:request, fn _, :get, "/_aliases", "", [] -> SearchHelpers.aliases_response() end)
      |> expect(:request, fn _,
                             :post,
                             url,
                             %{aggs: aggs, from: 0, query: query, size: 100},
                             opts ->
        assert opts == [params: %{"track_total_hits" => "true"}]
        assert url == "/structures_test_alias/_search"
        assert aggs == %{"_index" => %{terms: %{field: "_index"}}}

        assert query == %{
                 bool: %{
                   must: %{term: %{"_index" => "structures_test"}},
                   must_not: %{exists: %{field: "deleted_at"}}
                 }
               }

        SearchHelpers.hits_response([
          %{"_index" => "structures_test"},
          %{"_index" => "structures_test"},
          %{"_index" => "structures_test"},
          %{"_index" => "structures_test"}
        ])
      end)

      params = %{"indexes" => [@indices[:structures]]}

      assert %{"data" => data} =
               conn
               |> post(~p"/api/global_search", params)
               |> json_response(:ok)

      assert [%{"results" => results}] = data
      assert length(results) == 4
    end
  end

  describe "Regular user search" do
    @tag authentication: [role: "user", permissions: ["view_data_structure"]]
    test "Searches all indices by default", %{
      conn: conn,
      domain: %{id: domain_id}
    } do
      ElasticsearchMock
      |> expect(:request, fn _, :get, "/_aliases", "", [] -> SearchHelpers.aliases_response() end)
      |> expect(:request, fn _,
                             :post,
                             url,
                             %{aggs: aggs, from: 0, query: query, size: 100},
                             opts ->
        assert opts == [params: %{"track_total_hits" => "true"}]
        assert url == "/structures_test_alias/_search"
        assert aggs == %{"_index" => %{terms: %{field: "_index"}}}

        assert query == %{
                 bool: %{
                   must: [
                     %{term: %{"domain_ids" => domain_id}},
                     %{term: %{"_index" => "structures_test"}}
                   ],
                   must_not: [
                     %{term: %{"confidential" => true}},
                     %{exists: %{field: "deleted_at"}}
                   ]
                 }
               }

        SearchHelpers.hits_response([
          %{"_index" => "structures_test"},
          %{"_index" => "concepts_test"},
          %{"_index" => "ingests_test"},
          %{"_index" => "concepts_test"}
        ])
      end)

      assert %{"data" => data} =
               conn
               |> post(~p"/api/global_search")
               |> json_response(:ok)

      assert [%{"index" => "structures_test_alias", "results" => [_]}] = data
    end

    @tag authentication: [permissions: ["view_data_structure"]]
    test "Search only specified indices", %{conn: conn} do
      ElasticsearchMock
      |> expect(:request, fn _, :get, "/_aliases", "", [] -> SearchHelpers.aliases_response() end)
      |> expect(:request, fn _,
                             :post,
                             url,
                             %{aggs: aggs, from: 0, query: query, size: 100},
                             opts ->
        assert opts == [params: %{"track_total_hits" => "true"}]
        assert url == "/structures_test_alias/_search"
        assert aggs == %{"_index" => %{terms: %{field: "_index"}}}

        assert %{
                 bool: %{
                   must: [
                     %{term: %{"domain_ids" => _}},
                     %{term: %{"_index" => "structures_test"}}
                   ],
                   must_not: [
                     %{term: %{"confidential" => true}},
                     %{exists: %{field: "deleted_at"}}
                   ]
                 }
               } = query

        SearchHelpers.hits_response([
          %{"_index" => "structures_test"},
          %{"_index" => "structures_test"},
          %{"_index" => "structures_test"},
          %{"_index" => "structures_test"}
        ])
      end)

      params = %{"indexes" => [@indices[:structures]]}

      assert %{"data" => data} =
               conn
               |> post(~p"/api/global_search", params)
               |> json_response(:ok)

      assert [%{"results" => results}] = data
      assert length(results) == 4
    end
  end
end
