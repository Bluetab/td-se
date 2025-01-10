defmodule TdSe.GlobalSearchTest do
  use TdSeWeb.ConnCase

  import Mox

  alias TdCore.TestSupport.CacheHelpers
  alias TdSe.GlobalSearch

  @aliases %{
    "concepts_test_alias" => "concepts_test",
    "structures_test_alias" => "structures_test",
    "ingests_test_alias" => "ingests_test"
  }

  setup :put_permissions
  setup :verify_on_exit!

  describe "Search test" do
    @tag authentication: [user_name: "not_an_admin"]
    test "search multiple indices with a non admin user", %{
      claims: claims,
      domain_id: domain_id,
      other_id: other_id
    } do
      ElasticsearchMock
      |> expect(
        :request,
        fn _, :post, url, %{aggs: aggs, from: 0, query: query, size: 100}, opts ->
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
                             %{term: %{"domain_ids" => domain_id}},
                             %{term: %{"_index" => "concepts_test"}},
                             %{term: %{"status" => "published"}}
                           ],
                           must_not: %{term: %{"confidential.raw" => true}}
                         }
                       },
                       %{
                         bool: %{
                           must: [
                             %{term: %{"domain_ids" => other_id}},
                             %{term: %{"_index" => "structures_test"}}
                           ],
                           must_not: [
                             %{term: %{"confidential" => true}},
                             %{exists: %{field: "deleted_at"}}
                           ]
                         }
                       }
                     ]
                   }
                 }

          SearchHelpers.hits_response([
            %{"id" => 1, "foo" => "bar", "_index" => "concepts_test"},
            %{"id" => 2, "foo" => "bar", "_index" => "structures_test"}
          ])
        end
      )

      params = %{}

      assert %{results: [_, _], total: 2} = GlobalSearch.search(params, claims, @aliases, 0, 100)
    end

    @tag authentication: [user_name: "not_an_admin"]
    test "search concepts with a non admin user", %{
      claims: claims,
      domain_id: domain_id
    } do
      ElasticsearchMock
      |> expect(:request, fn _, :post, url, %{aggs: aggs, query: query, from: 0, size: 100}, _ ->
        assert url == "/concepts_test_alias/_search"
        assert aggs == %{"_index" => %{terms: %{field: "_index"}}}

        assert query == %{
                 bool: %{
                   must: [
                     %{term: %{"domain_ids" => domain_id}},
                     %{term: %{"_index" => "concepts_test"}},
                     %{term: %{"status" => "published"}}
                   ],
                   must_not: %{term: %{"confidential.raw" => true}}
                 }
               }

        SearchHelpers.hits_response([%{"id" => 1, "foo" => "bar", "_index" => "concepts_test"}])
      end)

      aliases = Map.take(@aliases, ["concepts_test_alias"])
      assert %{results: results, total: total} = GlobalSearch.search(%{}, claims, aliases, 0, 100)

      assert total == 1
      assert length(results) == 1
    end

    @tag authentication: [user_name: "not_an_admin"]
    test "search structures with a non admin user using a query", %{
      claims: claims,
      domain_id: domain_id,
      other_id: other_id
    } do
      ElasticsearchMock
      |> expect(
        :request,
        fn _, :post, url, %{aggs: aggs, from: 0, query: query, size: 100}, opts ->
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
                             %{
                               multi_match: %{
                                 fields: ["ngram_name*^3"],
                                 lenient: true,
                                 query: "Foo bar",
                                 fuzziness: "AUTO",
                                 type: "bool_prefix"
                               }
                             },
                             %{term: %{"domain_ids" => domain_id}},
                             %{term: %{"_index" => "concepts_test"}},
                             %{term: %{"status" => "published"}}
                           ],
                           must_not: %{term: %{"confidential.raw" => true}}
                         }
                       },
                       %{
                         bool: %{
                           must: [
                             %{
                               multi_match: %{
                                 fields: [
                                   "ngram_name*^3",
                                   "ngram_original_name*^1.5",
                                   "ngram_path*",
                                   "system.name"
                                 ],
                                 lenient: true,
                                 query: "Foo bar",
                                 fuzziness: "AUTO",
                                 type: "bool_prefix"
                               }
                             },
                             %{term: %{"domain_ids" => other_id}},
                             %{term: %{"_index" => "structures_test"}}
                           ],
                           must_not: [
                             %{term: %{"confidential" => true}},
                             %{exists: %{field: "deleted_at"}}
                           ]
                         }
                       }
                     ]
                   }
                 }

          SearchHelpers.hits_response([
            %{"_index" => "structures_test", "id" => 123, "name" => "Foo"}
          ])
        end
      )

      params = %{"query" => "Foo bar"}

      assert %{results: [%{"name" => name}], total: 1} =
               GlobalSearch.search(params, claims, @aliases, 0, 100)

      assert name == "Foo"
    end

    @tag authentication: [role: "admin"]
    test "search with an admin user should fetch all results filtered by status published in ingests and concepts",
         %{claims: claims} do
      ElasticsearchMock
      |> expect(
        :request,
        fn _, :post, url, %{aggs: aggs, from: 0, query: query, size: 100}, opts ->
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
                           must: [%{term: %{"_index" => "structures_test"}}],
                           must_not: %{exists: %{field: "deleted_at"}}
                         }
                       }
                     ]
                   }
                 }

          SearchHelpers.hits_response([
            %{"_index" => "structures_test", "id" => 123, "name" => "Foo"}
          ])
        end
      )

      assert %{results: [_], total: 1} = GlobalSearch.search(%{}, claims, @aliases, 0, 100)
    end

    @tag authentication: [user_name: "no_permissions"]
    test "search without any permissions", %{claims: claims} do
      params = %{"query" => "Stru"}
      assert GlobalSearch.search(params, claims, @aliases, 0, 100) == %{results: [], total: 0}
    end
  end

  defp put_permissions(%{claims: %{user_name: "no_permissions"}}), do: :ok

  defp put_permissions(%{claims: %{role: "user"} = claims}) do
    %{id: parent_id} = CacheHelpers.insert_domain()
    %{id: domain_id} = CacheHelpers.insert_domain(parent_id: parent_id)
    %{id: other_id} = CacheHelpers.insert_domain()

    CacheHelpers.put_session_permissions(claims, %{
      "view_draft_business_concepts" => [parent_id],
      "view_published_business_concepts" => [domain_id],
      "view_draft_ingests" => [domain_id],
      "view_data_structure" => [other_id]
    })

    [domain_id: domain_id, other_id: other_id]
  end

  defp put_permissions(_), do: :ok
end
