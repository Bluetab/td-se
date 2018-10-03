defmodule TdSe.GlobalSearchTest do
  @moduledoc false
  use ExUnit.Case, async: true
  alias TdPerms.MockPermissionResolver
  alias TdSe.ESClientApi
  alias TdSe.Factory
  alias TdSe.GlobalSearch
  use TdSeWeb.ConnCase

  @all_indexes Application.get_env(:td_se, :elastic_indexes)
  @user_permissions [
    %{
      permissions: [:view_draft_business_concepts, :view_published_business_concepts],
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
    #Delete elastic content
    query = %{query: %{match_all: %{}}}

    @all_indexes
      |> Enum.map(fn {_k, v} -> v end)
      |> Enum.map(&ESClientApi.delete_all_docs_by_query(&1, query))

    bulk_list =
      :code.priv_dir(:td_se)
      |> Path.join("static/bulk_content.json")
      |> File.read!()
      |> Poison.decode!()
      |> Map.fetch!("bulk_list")

    ESClientApi.bulk_index_content(bulk_list, "wait_for")
    :ok
  end

  describe "Search test" do
    @tag authenticated_user: %{user_name: "not_admin_user", permissions: @user_permissions}
    test "list indexes on which a not admin user has permissions", %{claims: claims} do
      user = Factory.build_user(claims)
      %{results: results, total: total} =
        GlobalSearch.search(
            %{"indexes" => ["business_concept_test", "data_structure_test"]},
            user,
            0,
            10_000
        )
      assert total == 3
      assert length(results) == 3
    end

    @tag :admin_authenticated
    test "list indexes with and admin user", %{claims: claims} do
      user = Factory.build_user(claims)
      %{results: results, total: total} =
        GlobalSearch.search(
            %{"indexes" => ["business_concept_test", "data_structure_test"]},
            user,
            0,
            10_000
        )
      assert total == 6
      assert length(results) == 6
    end
  end
end
