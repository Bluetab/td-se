defmodule TdSe.GlobalSearchTest do
  use TdSeWeb.ConnCase

  alias TdSe.GlobalSearch
  alias TdSe.Permissions.MockPermissionResolver
  alias TdSe.TestDataHelper

  @indices Application.compile_env(:td_se, :indices)
  @user_permissions [
    %{
      permissions: [
        :view_draft_business_concepts,
        :view_draft_ingests,
        :view_published_business_concepts
      ],
      resource_id: 2,
      resource_type: "domain"
    },
    %{
      permissions: [:view_draft_business_concepts, :view_published_business_concepts],
      resource_id: 3,
      resource_type: "domain"
    },
    %{
      permissions: [:view_data_structure],
      resource_id: 5,
      resource_type: "domain"
    }
  ]

  setup_all do
    start_supervised(MockPermissionResolver)
    :ok
  end

  setup do
    # Delete elastic content
    query = %{query: %{match_all: %{}}}
    TestDataHelper.clean_docs_from_indexes(@indices, query)
    TestDataHelper.bulk_test_data("static/bulk_content.json")
    :ok
  end

  describe "Search test" do
    @tag authenticated_user: "non_admin_user"
    @tag permissions: @user_permissions
    test "search over the indexes with a non admin user has permissions", %{claims: claims} do
      %{results: results, total: total} =
        GlobalSearch.search(
          %{
            "indexes" => [
              {"concepts_test_alias", "concepts_test"},
              {"structures_test_alias", "structures_test"},
              {"ingests_test_alias", "ingests_test"}
            ]
          },
          claims,
          0,
          10_000
        )

      assert total == 2
      assert length(results) == 2
    end

    @tag authenticated_user: "non_admin_user"
    @tag permissions: @user_permissions
    test "search over a concepts_test index with a non admin user", %{claims: claims} do
      %{results: results, total: total} =
        GlobalSearch.search(
          %{"indexes" => [{"concepts_test_alias", "concepts_test"}]},
          claims,
          0,
          10_000
        )

      assert total == 1
      assert length(results) == 1
    end

    @tag authenticated_user: "non_admin_user"
    @tag permissions: @user_permissions
    test "search over a structures_test index with a non admin user using a query", %{
      claims: claims
    } do
      %{results: results, total: total} =
        GlobalSearch.search(
          %{
            "query" => "Stru",
            "indexes" => [
              {"concepts_test_alias", "concepts_test"},
              {"structures_test_alias", "structures_test"},
              {"ingests_test_alias", "ingests_test"}
            ]
          },
          claims,
          0,
          10_000
        )

      assert total == 1
      assert length(results) == 1
      assert Enum.all?(results, &(&1["name"] == "My Structure 2"))
    end

    @tag :admin_authenticated
    test "search with an admin user should fetch all results filtered by status published in ingests and concepts",
         %{claims: claims} do
      %{results: results, total: total} =
        GlobalSearch.search(
          %{
            "indexes" => [
              {"concepts_test_alias", "concepts_test"},
              {"structures_test_alias", "structures_test"},
              {"ingests_test_alias", "ingests_test"}
            ]
          },
          claims,
          0,
          10_000
        )

      assert total == 6
      assert length(results) == 6
    end
  end
end
